module Fakepay
  class Client
    URL = 'https://www.fakepay.io/purchase'.freeze

    NetworkConnectionError = Class.new(StandardError)
    InvalidApiKey = Class.new(StandardError)

    def initialize(api_key: Rails.application.credentials.fakepay_client_api_key, http_client: Excon)
      @api_key = api_key
      @http_client = http_client
    end

    def charge_by_credit_card(amount:, card_number:, cvv:, expiration_month:, expiration_year:, zip_code:)
      send_request(
        amount: amount,
        card_number: card_number,
        cvv: cvv,
        expiration_month: expiration_month,
        expiration_year: expiration_year,
        zip_code: zip_code,
      )
    end

    def charge_by_token(amount:, token:)
      send_request(amount: amount, token: token)
    end

    private

    def send_request(payload)
      response = @http_client.post(
        URL,
        body: payload.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'Authorization' => "Token token=#{@api_key}",
        },
      )

      raise InvalidApiKey if response.status == 401

      handle_response(response)
    rescue Excon::Error => e
      raise NetworkConnectionError, e.message
    end

    def handle_response(response)
      body = JSON.parse(response.body)

      if response.status == 200 && body['success']
        ::Result.new(true, data: body['token'])
      else
        ::Result.new(false)
      end
    end
  end
end
