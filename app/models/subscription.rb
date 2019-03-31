class Subscription < ApplicationRecord
  enum plan: [:bronze_box, :silver_box, :gold_box]

  validates :customer_id, :plan, :token, :expires_on, presence: true
end
