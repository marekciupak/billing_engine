module Subscriptions
  class PlanAmountCalculator
    InvalidPlanError = Class.new(StandardError)

    def call(plan)
      case plan.to_sym
      when :bronze_box then '1999'
      when :silver_box then '4900'
      when :gold_box then '9900'
      else raise InvalidPlanError, 'Invalid plan'
      end
    end
  end
end
