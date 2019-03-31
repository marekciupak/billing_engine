require 'test_helper'

module Api
  module V1
    class AuthenticationControllerTest < ActionDispatch::IntegrationTest
      test 'post create' do
        post subscriptions_url, headers: {'Authorization' => 'Bearer sample_invalid_token'}

        assert_response :forbidden
      end
    end
  end
end
