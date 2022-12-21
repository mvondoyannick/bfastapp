class AddBusToHoraire < ActiveRecord::Migration[7.0]
  def change
    add_reference :horaires, :bus, null: true, foreign_key: true
  end
end
