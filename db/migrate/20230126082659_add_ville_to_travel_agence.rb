class AddVilleToTravelAgence < ActiveRecord::Migration[7.0]
  def change
    add_reference :travel_agences, :ville, null: true, foreign_key: true
  end
end
