class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.string :line1, null: false
      t.string :line2, null: false
      t.string :zip_code, null: false
      t.string :city, null: false

      t.timestamps
    end

    add_reference :addresses, :subscription, foreign_key: true, null: false
  end
end
