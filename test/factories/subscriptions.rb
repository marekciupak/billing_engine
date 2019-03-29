FactoryBot.define do
  factory :subscription do
    plan { Subscription.plans.keys.sample }
    token { SecureRandom.hex }
    renewed_at { rand(1.year).seconds.ago.to_date }
  end
end
