class Subscription < ApplicationRecord
  enum plan: [:bronze_box, :silver_box, :gold_box]

  validates :plan, :token, presence: true
end
