class CreateGazFournisseurs < ActiveRecord::Migration[7.0]
  def change
    create_table :gaz_fournisseurs do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.references :ville, null: true, foreign_key: true
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
