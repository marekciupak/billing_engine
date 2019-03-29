module Fakepay
  class Client
    URL = 'https://www.fakepay.io/purchase'.freeze
    ERROR_CODES = {
      1_000_001 => 'Invalid credit card number',
      1_000_002 => 'Insufficient funds',
      1_000_003 => 'CVV failure',
      1_000_004 => 'Expired card',
      1_000_005 => 'Invalid zip code',
      1_000_006 => 'Invalid purchase amount',
      1_000_007 => 'Invalid token',
      1_000_008 => 'Invalid params',
    }.freeze

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
        error_message = ERROR_CODES.fetch(body['error_code'])
        ::Result.new(false, errors: [error_message])
      end
    end
  end
end
