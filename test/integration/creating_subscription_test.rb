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

  test 'can get errors in the response' do
    post '/subscriptions', params: {
      shipping_address: {
        line1: 'Bilbo Baggins',
        line2: 'Bag End, at the end of Bagshot Row',
      },
      plan: 'bronze_box',
    }

    assert_response(400)
    assert_equal({
      'errors' => {
        'shipping_address' => {
          'zip_code' => ['is missing'],
          'city' => ['is missing'],
        },
        'credit_card' => ['is missing'],
      },
    }, JSON.parse(response.body))
  end
end
