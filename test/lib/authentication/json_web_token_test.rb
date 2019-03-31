require 'test_helper'

module Authentication
  class JsonWebTokenTest < ActiveSupport::TestCase
    include ActiveSupport::Testing::TimeHelpers

    def setup
      @jwt_wrapper = JsonWebToken.new(secret_key: '12345'.freeze, algorithm: 'HS256'.freeze)
    end

    def test_encode_the_token
      payload = {
        'exp' => 1_515_974_400,
        'nbf' => 1_514_764_800,
      }

      token = @jwt_wrapper.encode(payload)

      expected = 'eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1MTU5NzQ0MDAsIm5iZiI6MTUxNDc2NDgwMH0.'\
      'u9_sqBAHXWwCZIPefk8itPcT5hHwG61qmEc7JxBg-zU'
      assert_equal(expected, token)
    end

    def test_decode_valid_token
      token = 'eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1MTU5NzQ0MDAsIm5iZiI6MTUxNDc2NDgwMH0.'\
        'u9_sqBAHXWwCZIPefk8itPcT5hHwG61qmEc7JxBg-zU'

      payload = travel_to(Time.utc(2018, 1, 14)) { @jwt_wrapper.decode(token) }

      assert_equal(1_515_974_400, payload['exp'])
      assert_equal(1_514_764_800, payload['nbf'])
    end

    def test_raise_exception_for_the_nil_token
      token = nil

      error = assert_raises(JsonWebToken::InvalidTokenError) { @jwt_wrapper.decode(token) }
      assert_equal('Nil JSON web token', error.message)
    end

    def test_raise_exception_for_the_empty_token
      token = ''

      error = assert_raises(JsonWebToken::InvalidTokenError) { @jwt_wrapper.decode(token) }
      assert_equal('Not enough or too many segments', error.message)
    end

    def test_raise_exception_for_the_token_in_invalid_format
      token = 'invalid'

      error = assert_raises(JsonWebToken::InvalidTokenError) { @jwt_wrapper.decode(token) }
      assert_equal('Not enough or too many segments', error.message)
    end

    def test_raise_exception_for_invalid_token
      token = 'eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1MTU5NzQ0MDAsIm5iZiI6MTUxNDc2NDgwMH0.'\
        'u9_sqBAHXWwCZIPefk8itPcT5hHwG61qmEc7JxBg-zu'

      error = assert_raises(JsonWebToken::InvalidTokenError) { @jwt_wrapper.decode(token) }
      assert_equal('Signature verification raised', error.message)
    end

    def test_raise_exception_for_immature_token
      token = 'eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1MTU5NzQ0MDAsIm5iZiI6MTUxNDc2NDgwMH0.'\
        'u9_sqBAHXWwCZIPefk8itPcT5hHwG61qmEc7JxBg-zU'

      travel_to(Time.utc(2017, 12, 31)) do
        error = assert_raises(JsonWebToken::InvalidTokenError) { @jwt_wrapper.decode(token) }
        assert_equal('Signature nbf has not been reached', error.message)
      end
    end
  end
end
