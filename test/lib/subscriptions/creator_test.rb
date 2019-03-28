require 'test_helper'

module Subscriptions
  class CreatorTest < Minitest::Test
    def setup
      @payment_gateway_client = stub('payment_gateway_client')
      @subject = Creator.new(payment_gateway_client: @payment_gateway_client)
    end

    def test_invalid_params
      result = @subject.call(
        credit_card: {
          numer: '4242424242424242',
        },
        plan: 'bronze_box',
      )

      assert_equal(false, result.success?)
      assert_equal({
        shipping_address: ['is missing'],
        credit_card: {
          expiration_month: ['is missing'],
          expiration_year: ['is missing'],
          cvv: ['is missing'],
          zip_code: ['is missing'],
        },
      }, result.errors)
    end

    def test_charging_the_credit_card
      @payment_gateway_client
        .stubs(:charge_by_credit_card)
        .with { |args| assert_equal('1999', args[:amount]) }
        .returns(::Result.new(true))

      result = @subject.call(
        shipping_address: {
          line1: 'Bilbo Baggins',
          line2: 'Bag End, at the end of Bagshot Row',
          zip_code: '12-345',
          city: 'Hobbiton',
        },
        credit_card: {
          numer: '4242424242424242',
          expiration_month: '06',
          expiration_year: '2021',
          cvv: '123',
          zip_code: '12-345',
        },
        plan: 'bronze_box',
      )

      assert_equal(true, result.success?)
      # TODO: assert db record
    end

    def test_failed_credit_card_transaction
      @payment_gateway_client.stubs(:charge_by_credit_card).returns(::Result.new(false, errors: [:insufficient_funds]))

      result = @subject.call(
        shipping_address: {
          line1: 'Bilbo Baggins',
          line2: 'Bag End, at the end of Bagshot Row',
          zip_code: '12-345',
          city: 'Hobbiton',
        },
        credit_card: {
          numer: '4242424242424242',
          expiration_month: '06',
          expiration_year: '2021',
          cvv: '123',
          zip_code: '12-345',
        },
        plan: 'bronze_box',
      )

      assert_equal(false, result.success?)
      assert_equal([:insufficient_funds], result.errors)
    end
  end
end
