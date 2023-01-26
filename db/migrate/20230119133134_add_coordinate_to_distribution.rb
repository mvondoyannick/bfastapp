class AddCoordinateToDistribution < ActiveRecord::Migration[7.0]
  def change
    add_column :distributions, :latitude, :float
    add_column :distributions, :longitude, :float
  end
end
