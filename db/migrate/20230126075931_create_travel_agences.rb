class CreateTravelAgences < ActiveRecord::Migration[7.0]
  def change
    create_table :travel_agences do |t|
      t.string :name
      t.float :latitude
      t.float :longitude
      t.boolean :active
      t.references :travel_entreprise, null: true, foreign_key: true

      t.timestamps
    end
  end
end
