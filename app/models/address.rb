class Address < ApplicationRecord
  validates :line1, :line2, :zip_code, :city, presence: true
  belongs_to :subscription
end
