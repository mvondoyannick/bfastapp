class AddNameToSettings < ActiveRecord::Migration[7.0]
  def change
    add_column :settings, :name, :string
  end
end
