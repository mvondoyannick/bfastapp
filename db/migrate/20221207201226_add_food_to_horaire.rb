class AddFoodToHoraire < ActiveRecord::Migration[7.0]
  def change
    add_reference :horaires, :food, null: true, foreign_key: true
  end
end
