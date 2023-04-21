class AddTailleToCustomer < ActiveRecord::Migration[7.0]
  def change
    add_column :customers, :taille, :string
  end
end
