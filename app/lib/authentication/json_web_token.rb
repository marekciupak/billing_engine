module Authentication
  class JsonWebToken
    InvalidTokenError = Class.new(StandardError)

    def initialize(secret_key: Rails.application.credentials.jwt_secret_key, algorithm: 'HS256'.freeze)
      @secret_key = secret_key
      @algorithm = algorithm
    end

    def encode(payload)
      ::JWT.encode(payload, secret_key, algorithm)
    end

    def decode(token)
      ::JWT.decode(token, secret_key, true, algorithm: algorithm).first
    rescue ::JWT::DecodeError, ::JWT::VerificationError, ::JWT::ImmatureSignature => exception
      raise InvalidTokenError, exception
    end

    private

    attr_reader :secret_key, :algorithm
  end
end
