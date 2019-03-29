module Subscriptions
  class Renewer
    SUBSCRIPTION_PERIOD = 30.days

    def initialize(plan_amount_calculator: PlanAmountCalculator.new, payment_gateway_client: ::Fakepay::Client.new)
      @plan_amount_calculator = plan_amount_calculator
      @payment_gateway_client = payment_gateway_client
    end

    def call(billing_date)
      subscriptions = Subscription.where(renewed_at: billing_date - SUBSCRIPTION_PERIOD).all

      subscriptions.each do |subscription|
        amount = @plan_amount_calculator.call(subscription.plan)
        result = @payment_gateway_client.charge_by_token(amount: amount, token: subscription.token)

        if result.success?
          subscription.update!(renewed_at: billing_date)
        end
      end
    end
  end
end
