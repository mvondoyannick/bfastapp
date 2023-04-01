class AddRappelToCustomer < ActiveRecord::Migration[7.0]
  def change
    add_column :customers, :rappel, :string
  end
end
