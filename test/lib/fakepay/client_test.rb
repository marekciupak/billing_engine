require 'test_helper'

module Fakepay
  class ClientTest < ActiveSupport::TestCase
    def setup
      @subject = Client.new(api_key: 'abcd')
    end

    def test_charge_by_credit_card
      stub_request(:post, 'https://www.fakepay.io/purchase').with(
        body: '{"amount":"1000","card_number":"4242424242424242","cvv":"123","expiration_month":"01",'\
              '"expiration_year":"2024","zip_code":"10045"}',
        headers: {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'Authorization' => 'Token token=abcd',
        },
      ).to_return(
        status: 200,
        body: '{"token":"123456","success":true,"error_code":null}',
      )

      result = @subject.charge_by_credit_card(
        amount: '1000',
        card_number: '4242424242424242',
        cvv: '123',
        expiration_month: '01',
        expiration_year: '2024',
        zip_code: '10045',
      )

      assert(result.success?)
      assert_equal('123456', result.data)
    end

    def test_charge_by_token
      stub_request(:post, 'https://www.fakepay.io/purchase').with(
        body: '{"amount":"1000","token":"1234512345"}',
        headers: {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'Authorization' => 'Token token=abcd',
        },
      ).to_return(
        status: 200,
        body: '{"token":"1234512345","success":true,"error_code":null}',
      )

      result = @subject.charge_by_token(amount: '1000', token: '1234512345')

      assert(result.success?)
      assert_equal('1234512345', result.data)
    end

    def test_handeling_invalid_card_number_response
      stub_request(:post, 'https://www.fakepay.io/purchase').with(
        body: '{"amount":"1000","card_number":"4242424242424241","cvv":"123","expiration_month":"01",'\
              '"expiration_year":"2024","zip_code":"10045"}',
        headers: {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'Authorization' => 'Token token=abcd',
        },
      ).to_return(
        status: 422,
        body: '{"token":"123456","success":false,"error_code":1000001}',
      )

      result = @subject.charge_by_credit_card(
        amount: '1000',
        card_number: '4242424242424241',
        cvv: '123',
        expiration_month: '01',
        expiration_year: '2024',
        zip_code: '10045',
      )

      assert_equal(false, result.success?)
      assert_equal({payment: 'Invalid credit card number'}, result.errors)
    end
  end
end
