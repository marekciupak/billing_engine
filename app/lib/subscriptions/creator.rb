module Subscriptions
  class Creator
    InvalidPlanError = Class.new(StandardError)

    def initialize(payment_gateway_client: ::Fakepay::Client.new)
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
      result = @payment_gateway_client.charge_by_credit_card(
        amount: amount(form.plan),
        card_number: form.credit_card.numer,
        cvv: form.credit_card.cvv,
        expiration_month: form.credit_card.expiration_month,
        expiration_year: form.credit_card.expiration_year,
        zip_code: form.credit_card.zip_code,
      )

      if result.success?
        store_subscription_in_db(form: form, token: result.data)
        Result.new(true)
      else
        Result.new(false, errors: result.errors)
      end
    end

    def amount(plan)
      case plan.to_sym
      when :bronze_box then '1999'
      when :silver_box then '4900'
      when :gold_box then '9900'
      else raise InvalidPlanError, 'Invalid plan'
      end
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
