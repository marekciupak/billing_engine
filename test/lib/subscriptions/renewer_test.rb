require 'test_helper'

module Subscriptions
  class RenewerTest < ActiveSupport::TestCase
    def setup
      @payment_gateway_client = stub('payment_gateway_client')
      @subject = Renewer.new(payment_gateway_client: @payment_gateway_client)
    end

    def test_no_subscriptions_to_renew
      create(:subscription, plan: :silver_box, token: 'qwerty1', expires_on: Date.new(2019, 1, 29))
      create(:subscription, plan: :silver_box, token: 'qwerty2', expires_on: Date.new(2019, 1, 31))

      results = @subject.call(Date.new(2019, 1, 30))

      assert_equal({}, results)
    end

    def test_renew_subscriptions
      subscription1 = create(:subscription, plan: :silver_box, token: 'qwerty1', expires_on: Date.new(2019, 1, 30))
      subscription2 = create(:subscription, plan: :gold_box, token: 'qwerty2', expires_on: Date.new(2019, 1, 30))
      subscription3 = create(:subscription, plan: :silver_box, token: 'qwerty3', expires_on: Date.new(2019, 1, 31))

      @payment_gateway_client
        .stubs(:charge_by_token)
        .with { |args| args[:amount] == '4900' && args[:token] == 'qwerty1' }
        .returns(::Result.new(true, data: 'abc2'))
      @payment_gateway_client
        .stubs(:charge_by_token)
        .with { |args| args[:amount] == '9900' && args[:token] == 'qwerty2' }
        .returns(::Result.new(false))

      results = @subject.call(Date.new(2019, 1, 30))

      assert_equal(Date.new(2019, 3, 1), subscription1.reload.expires_on)
      assert_equal(Date.new(2019, 1, 30), subscription2.reload.expires_on)
      assert_equal(Date.new(2019, 1, 31), subscription3.reload.expires_on)
      assert_equal({subscription1.id => true, subscription2.id => false}, results)
    end
  end
end
