require 'test_helper'

class CreatingCustomerTest < ActionDispatch::IntegrationTest
  test 'can create customer account' do
    post '/customers'

    body = JSON.parse(response.body)
    token = body.fetch('bearer_token')
    customer_id = body.fetch('customer').fetch('id')

    assert_response(201)
    assert(customer_id.present?)
    assert(::Authentication::JsonWebToken.new.decode(token).fetch('customer_id') == customer_id)
  end
end
