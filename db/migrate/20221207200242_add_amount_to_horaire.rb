class AddAmountToHoraire < ActiveRecord::Migration[7.0]
  def change
    add_column :horaires, :amount, :string
  end
end
