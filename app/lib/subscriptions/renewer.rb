module Subscriptions
  class Renewer
    def initialize(plan_amount_calculator: PlanAmountCalculator.new, payment_gateway_client: ::Fakepay::Client.new)
      @plan_amount_calculator = plan_amount_calculator
      @payment_gateway_client = payment_gateway_client
    end

    def call(billing_date)
      subscriptions = Subscription.where(renewed_at: billing_date - Subscription::SUBSCRIPTION_PERIOD).all
      subscriptions.map { |subscription| [subscription.id, renew_subscription(subscription, billing_date)] }.to_h
    end

    private

    def renew_subscription(subscription, billing_date)
      amount = @plan_amount_calculator.call(subscription.plan)
      result = @payment_gateway_client.charge_by_token(amount: amount, token: subscription.token)

      if result.success?
        subscription.update!(renewed_at: billing_date)
        true
      else
        false
      end
    end
  end
end
