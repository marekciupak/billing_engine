class CustomersController < ApplicationController
  def create
    customer_id = SecureRandom.uuid
    bearer_token = issue_bearer_token(customer_id)

    render json: {customer: {id: customer_id}, bearer_token: bearer_token}, status: :created
  end

  private

  def issue_bearer_token(customer_id)
    claims = {
      iat: Time.current.to_i,
      customer_id: customer_id,
    }
    ::Authentication::JsonWebToken.new.encode(claims)
  end
end
