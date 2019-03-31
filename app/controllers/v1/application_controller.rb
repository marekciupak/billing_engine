module V1
  class ApplicationController < ActionController::API
    def require_authentication!
      render_unauthorized unless current_customer_id
    end

    def current_customer_id
      @current_customer_id ||=
        if bearer_token.present?
          ::Authentication::JsonWebToken.new.decode(bearer_token).fetch('customer_id')
        end
    rescue ::Authentication::JsonWebToken::InvalidTokenError => _e
      render_unauthorized
    end

    private

    def bearer_token
      @bearer_token ||= request.headers['Authorization'].to_s[/^Bearer (.*)$/, 1]
    end

    def render_unauthorized
      render json: {errors: {authorization: 'Invalid or blank bearer token!'}}, status: :forbidden
    end
  end
end
