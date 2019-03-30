class AddExpiresOnToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :expires_on, :date, null: false
  end
end
