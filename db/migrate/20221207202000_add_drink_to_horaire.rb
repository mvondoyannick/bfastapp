class AddDrinkToHoraire < ActiveRecord::Migration[7.0]
  def change
    add_reference :horaires, :drink, null: true, foreign_key: true
  end
end
