class CreateReservations < ActiveRecord::Migration[7.0]
  def change
    create_table :reservations do |t|
      t.references :horaire, null: true, foreign_key: true
      t.references :bus, null: true, foreign_key: true
      t.references :ville, null: true, foreign_key: true
      t.string :customer_name
      t.string :customer_second_name
      t.string :customer_phone

      t.timestamps
    end
  end
end
