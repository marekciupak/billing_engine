module Subscriptions
  class Creator
    def initialize(plan_amount_calculator: PlanAmountCalculator.new, payment_gateway_client: ::Fakepay::Client.new)
      @plan_amount_calculator = plan_amount_calculator
      @payment_gateway_client = payment_gateway_client
    end

    def call(params)
      result = CreateFormSchema.call(params)

      if result.success?
        form = CreateForm.new(result)
        create_subscription(form)
      else
        Result.new(false, errors: result.errors)
      end
    end

    private

    def create_subscription(form)
      result = charge(form)

      if result.success?
        store_subscription_in_db(form: form, token: result.data)
        Result.new(true)
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

    def store_subscription_in_db(form:, token:)
      ActiveRecord::Base.transaction do
        subscription = Subscription.create!(plan: form.plan.to_sym, token: token, renewed_at: Time.zone.today)
        Address.create!(
          subscription: subscription,
          line1: form.shipping_address.line1,
          line2: form.shipping_address.line2,
          zip_code: form.shipping_address.zip_code,
          city: form.shipping_address.city,
        )
      end
    end
  end
end
