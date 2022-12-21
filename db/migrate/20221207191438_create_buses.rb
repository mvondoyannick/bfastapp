class CreateBuses < ActiveRecord::Migration[7.0]
  def change
    create_table :buses do |t|
      t.string :name
      t.string :immatriculation
      t.string :chassis
      t.string :brand
      t.string :modele

      t.timestamps
    end
  end
end
