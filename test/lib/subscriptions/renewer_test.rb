require 'test_helper'

module Subscriptions
  class RenewerTest < ActiveSupport::TestCase
    def setup
      @payment_gateway_client = stub('payment_gateway_client')
      @subject = Renewer.new(payment_gateway_client: @payment_gateway_client)
    end

    def test_no_subscriptions_to_renew
      create(:subscription, plan: :silver_box, token: 'qwerty1', renewed_at: Date.new(2018, 12, 30))
      create(:subscription, plan: :silver_box, token: 'qwerty2', renewed_at: Date.new(2019, 1, 1))

      results = @subject.call(Date.new(2019, 1, 30))

      assert_equal({}, results)
    end

    def test_renew_subscriptions
      subscription1 = create(:subscription, plan: :silver_box, token: 'qwerty1', renewed_at: Date.new(2018, 12, 30))
      subscription2 = create(:subscription, plan: :silver_box, token: 'qwerty2', renewed_at: Date.new(2018, 12, 31))
      subscription3 = create(:subscription, plan: :gold_box, token: 'qwerty3', renewed_at: Date.new(2018, 12, 31))

      @payment_gateway_client
        .stubs(:charge_by_token)
        .with { |args| args[:amount] == '4900' && args[:token] == 'qwerty2' }
        .returns(::Result.new(true, data: 'abc2'))
      @payment_gateway_client
        .stubs(:charge_by_token)
        .with { |args| args[:amount] == '9900' && args[:token] == 'qwerty3' }
        .returns(::Result.new(false))

      results = @subject.call(Date.new(2019, 1, 30))

      assert_equal(Date.new(2018, 12, 30), subscription1.reload.renewed_at)
      assert_equal(Date.new(2019, 1, 30), subscription2.reload.renewed_at)
      assert_equal(Date.new(2018, 12, 31), subscription3.reload.renewed_at)
      assert_equal({subscription2.id => true, subscription3.id => false}, results)
    end
  end
end
