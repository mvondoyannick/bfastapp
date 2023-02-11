class AddActiveToCustomer < ActiveRecord::Migration[7.0]
  def change
    add_column :customers, :active, :boolean
    add_column :customers, :verified, :boolean
  end
end
