class AddDepartureToHoraire < ActiveRecord::Migration[7.0]
  def change
    add_column :horaires, :departure, :datetime
  end
end
