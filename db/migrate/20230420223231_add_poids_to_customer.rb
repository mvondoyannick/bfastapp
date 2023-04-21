class AddPoidsToCustomer < ActiveRecord::Migration[7.0]
  def change
    add_column :customers, :poids, :string
  end
end
