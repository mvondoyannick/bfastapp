class CreateGazBottlesFournisseurs < ActiveRecord::Migration[7.0]
  def change
    create_table :gaz_bottles_fournisseurs do |t|
      t.references :gaz_fournisseur, null: false, foreign_key: true
      t.references :gaz_bottle, null: false, foreign_key: true

      t.timestamps
    end
  end
end
