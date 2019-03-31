FactoryBot.define do
  factory :subscription do
    customer_id { SecureRandom.uuid }
    plan { Subscription.plans.keys.sample }
    token { SecureRandom.hex }
    expires_on { rand(1.month).seconds.from_now.to_date }
  end
end
