class AddTokenToTravelEntreprise < ActiveRecord::Migration[7.0]
  def change
    add_column :travel_entreprises, :token, :text
  end
end
