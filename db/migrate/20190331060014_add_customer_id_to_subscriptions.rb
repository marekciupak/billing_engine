class AddCustomerIdToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :customer_id, :string, null: false
    add_index :subscriptions, :customer_id
  end
end
