module Subscription
  class CreateForm < Dry::Struct
    attribute :shipping_address do
      attribute :line1, Types::Strict::String
      attribute :line2, Types::Strict::String
      attribute :zip_code, Types::Strict::String
      attribute :city, Types::Strict::String
    end

    attribute :credit_card do
      attribute :numer, Types::Strict::String
      attribute :expiration_month, Types::Strict::String
      attribute :expiration_year, Types::Strict::String
      attribute :cvv, Types::Strict::String
      attribute :zip_code, Types::Strict::String
    end

    attribute :plan, Types::Strict::String
  end
end
