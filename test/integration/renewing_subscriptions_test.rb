require 'test_helper'
require 'rake'

class RenewingSubscriptionsTest < ActiveSupport::TestCase
  def test_renew_subscriptions
    subscription1 = create(
      :subscription,
      plan: :silver_box,
      token: '1f98fab6dd2e7364783c8e1a586336',
      expires_on: Date.new(2019, 1, 30),
    )
    subscription2 = create(:subscription, plan: :gold_box, expires_on: Date.new(2019, 1, 31))

    VCR.use_cassette('a successful purchase with token from a previously successful purchase') do
      execute_rake_task('subscriptions:renew', '2019', '1', '30')
    end

    assert_equal(Date.new(2019, 3, 1), subscription1.reload.expires_on)
    assert_equal(Date.new(2019, 1, 31), subscription2.reload.expires_on)
  end

  private

  def execute_rake_task(task, *args)
    BillingEngine::Application.load_tasks
    Rake::Task[task].invoke(*args)
  end
end
