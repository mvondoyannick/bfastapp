class AddRappelDayToCustomer < ActiveRecord::Migration[7.0]
  def change
    add_column :customers, :rappel_day, :string
  end
end
