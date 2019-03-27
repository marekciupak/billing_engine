module Subscription
  CreateFormSchema = Dry::Validation.Params do
    required(:shipping_address).schema do
      required(:line1).filled
      required(:line2).filled
      required(:zip_code).filled
      required(:city).filled
    end

    required(:credit_card).schema do
      required(:numer).filled
      required(:expiration_month).filled
      required(:expiration_year).filled
      required(:cvv).filled
      required(:zip_code).filled
    end

    required(:plan).filled
  end
end
