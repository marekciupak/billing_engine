class Subscription < ApplicationRecord
  SUBSCRIPTION_PERIOD = 30.days

  enum plan: [:bronze_box, :silver_box, :gold_box]

  validates :plan, :token, :expires_on, presence: true
end
