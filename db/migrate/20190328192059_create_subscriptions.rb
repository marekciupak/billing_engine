class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.integer :plan, null: false
      t.string :token, null: false

      t.timestamps
    end
  end
end
