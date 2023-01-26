class CreateDistributions < ActiveRecord::Migration[7.0]
  def change
    create_table :distributions do |t|
      t.string :name
      t.string :phone
      t.string :email
      t.string :ville
      t.references :entreprise, null: true, foreign_key: true

      t.timestamps
    end
  end
end
