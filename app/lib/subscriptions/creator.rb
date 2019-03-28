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
        Result.new(true)
      else
        Result.new(false, errors: result.errors)
      end
    end

    def amount(plan)
      case plan
      when 'bronze_box' then '1999'
      when 'silver_box' then '4900'
      when 'gold_box' then '9900'
      else raise InvalidPlanError, 'Invalid plan'
      end
    end
  end
end
