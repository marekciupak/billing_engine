require 'test_helper'

class CreatingSubscriptionTest < ActionDispatch::IntegrationTest
  test 'can create subscription' do
    post '/subscriptions', params: {
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
    }

    assert_response(201)
  end
end
