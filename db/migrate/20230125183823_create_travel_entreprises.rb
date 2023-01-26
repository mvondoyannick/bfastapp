class CreateTravelEntreprises < ActiveRecord::Migration[7.0]
  def change
    create_table :travel_entreprises do |t|
      t.string :name
      t.string :phone
      t.string :email

      t.timestamps
    end
  end
end
