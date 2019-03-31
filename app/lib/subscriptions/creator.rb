module Subscriptions
  class Creator
    def initialize(plan_amount_calculator: PlanAmountCalculator.new, payment_gateway_client: ::Fakepay::Client.new)
      @plan_amount_calculator = plan_amount_calculator
      @payment_gateway_client = payment_gateway_client
    end

    def call(customer_id:, params:)
      result = CreateFormSchema.call(params)

      if result.success?
        form = CreateForm.new(result)
        create_subscription(customer_id, form)
      else
        Result.new(false, errors: {params: result.errors})
      end
    end

    private

    def create_subscription(customer_id, form)
      result = charge(form)

      if result.success?
        subscription = store_subscription_in_db(customer_id: customer_id, form: form, token: result.data)
        Result.new(true, data: subscription)
      else
        Result.new(false, errors: result.errors)
      end
    end

    def charge(form)
      amount = @plan_amount_calculator.call(form.plan)

      @payment_gateway_client.charge_by_credit_card(
        amount: amount,
        card_number: form.credit_card.numer,
        cvv: form.credit_card.cvv,
        expiration_month: form.credit_card.expiration_month,
        expiration_year: form.credit_card.expiration_year,
        zip_code: form.credit_card.zip_code,
      )
    end

    def store_subscription_in_db(customer_id:, form:, token:)
      ActiveRecord::Base.transaction do
        subscription = Subscription.create!(
          customer_id: customer_id,
          plan: form.plan.to_sym,
          token: token,
          expires_on: Time.zone.today.next_month,
        )
        Address.create!(
          subscription: subscription,
          line1: form.shipping_address.line1,
          line2: form.shipping_address.line2,
          zip_code: form.shipping_address.zip_code,
          city: form.shipping_address.city,
        )

        subscription
      end
    end
  end
end
