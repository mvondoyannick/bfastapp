class RemoveBusFromHoraire < ActiveRecord::Migration[7.0]
  def change
    remove_reference :horaires, :bus, null: true, foreign_key: true
    remove_reference :horaires, :drink, null: true, foreign_key: true
    remove_reference :horaires, :food, null: true, foreign_key: true
    remove_column :horaires, :amount, :string
  end
end
