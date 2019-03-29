module Subscriptions
  class Renewer
    InvalidPlanError = Class.new(StandardError) # DUP

    SUBSCRIPTION_PERIOD = 30.days

    def initialize(payment_gateway_client: ::Fakepay::Client.new)
      @payment_gateway_client = payment_gateway_client
    end

    def call(billing_date)
      subscriptions = Subscription.where(renewed_at: billing_date - SUBSCRIPTION_PERIOD).all

      subscriptions.each do |subscription|
        result = @payment_gateway_client.charge_by_token(amount: amount(subscription.plan), token: subscription.token)

        if result.success?
          subscription.update!(renewed_at: billing_date)
        end
      end
    end

    private

    # DUP:
    def amount(plan)
      case plan.to_sym
      when :bronze_box then '1999'
      when :silver_box then '4900'
      when :gold_box then '9900'
      else raise InvalidPlanError, 'Invalid plan'
      end
    end
  end
end
