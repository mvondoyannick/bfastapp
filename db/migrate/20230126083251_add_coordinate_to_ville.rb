class AddCoordinateToVille < ActiveRecord::Migration[7.0]
  def change
    add_column :villes, :latitude, :float
    add_column :villes, :longitude, :float
    add_column :villes, :active, :boolean
  end
end
