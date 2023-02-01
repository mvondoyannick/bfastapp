class CreateGazBottles < ActiveRecord::Migration[7.0]
  def change
    create_table :gaz_bottles do |t|
      t.string :name
      t.string :modele
      t.references :gaz_fournisseur, null: true, foreign_key: true
      t.references :gaz_manufacturer, null: true, foreign_key: true
      t.string :amount
      t.text :token

      t.timestamps
    end
  end
end
