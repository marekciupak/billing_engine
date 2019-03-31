class AddIndexesToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_index :subscriptions, :token, unique: true
    add_index :subscriptions, :expires_on
  end
end
