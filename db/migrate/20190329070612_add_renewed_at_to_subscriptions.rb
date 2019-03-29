class AddRenewedAtToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :renewed_at, :date, null: false
  end
end
