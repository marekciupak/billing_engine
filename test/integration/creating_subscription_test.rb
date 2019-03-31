require 'test_helper'

class CreatingSubscriptionTest < ActionDispatch::IntegrationTest
  def setup
    @bearer_token = ::Authentication::JsonWebToken.new.encode(iat: Time.current.to_i, customer_id: 'customer_1')
  end

  test 'requires authorization' do
    post(
      '/subscriptions',
      params: {
        shipping_address: {
          line1: 'Bilbo Baggins',
          line2: 'Bag End, at the end of Bagshot Row',
          zip_code: '12345',
          city: 'Hobbiton',
        },
        credit_card: {
          numer: '4242424242424242',
          expiration_month: '06',
          expiration_year: '2021',
          cvv: '123',
          zip_code: '12345',
        },
        plan: 'bronze_box',
      },
    )

    assert_response(403)
    assert_equal({'errors' => {'authorization' => 'Invalid or blank bearer token!'}}, JSON.parse(response.body))
  end

  test 'can create subscription' do
    travel_to(Date.new(2019, 2, 1)) do
      VCR.use_cassette('a successful purchase') do
        post(
          '/subscriptions',
          headers: {
            'Authorization' => "Bearer #{@bearer_token}",
          },
          params: {
            shipping_address: {
              line1: 'Bilbo Baggins',
              line2: 'Bag End, at the end of Bagshot Row',
              zip_code: '12345',
              city: 'Hobbiton',
            },
            credit_card: {
              numer: '4242424242424242',
              expiration_month: '06',
              expiration_year: '2021',
              cvv: '123',
              zip_code: '12345',
            },
            plan: 'bronze_box',
          },
        )
      end
    end

    assert_response(201)
    assert_equal('customer_1', JSON.parse(response.body)['subscription']['customer_id'])
    assert_equal('2019-03-01', JSON.parse(response.body)['subscription']['expires_on'])
    assert_equal(1, Subscription.count)
  end

  test 'can get errors in the response' do
    post(
      '/subscriptions',
      headers: {
        'Authorization' => "Bearer #{@bearer_token}",
      },
      params: {
        shipping_address: {
          line1: 'Bilbo Baggins',
          line2: 'Bag End, at the end of Bagshot Row',
        },
        plan: 'bronze_box',
      },
    )

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

  test 'can get invalid Fakepay API key error' do
    Rails.application.credentials.stubs(:fakepay_client_api_key!).returns('a_bad_token')

    assert_raises Fakepay::Client::InvalidApiKey do
      VCR.use_cassette('attempting a purchase with invalid API credentials') do
        post(
          '/subscriptions',
          headers: {
            'Authorization' => "Bearer #{@bearer_token}",
          },
          params: {
            shipping_address: {
              line1: 'Bilbo Baggins',
              line2: 'Bag End, at the end of Bagshot Row',
              zip_code: '12345',
              city: 'Hobbiton',
            },
            credit_card: {
              numer: '4242424242424242',
              expiration_month: '06',
              expiration_year: '2021',
              cvv: '123',
              zip_code: '12345',
            },
            plan: 'bronze_box',
          },
        )
      end
    end
  end

  test 'can get invalid card number error' do
    VCR.use_cassette('attempting a purchase with an invalid card number') do
      post(
        '/subscriptions',
        headers: {
          'Authorization' => "Bearer #{@bearer_token}",
        },
        params: {
          shipping_address: {
            line1: 'Bilbo Baggins',
            line2: 'Bag End, at the end of Bagshot Row',
            zip_code: '12345',
            city: 'Hobbiton',
          },
          credit_card: {
            numer: '4242424242424241',
            expiration_month: '06',
            expiration_year: '2021',
            cvv: '123',
            zip_code: '12345',
          },
          plan: 'bronze_box',
        },
      )
    end

    assert_response(400)
    assert_equal({
      'errors' => {'payment' => 'Invalid credit card number'},
    }, JSON.parse(response.body))
  end
end
