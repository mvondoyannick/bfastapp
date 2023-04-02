class AddDateRappelToCustomer < ActiveRecord::Migration[7.0]
  def change
    add_column :customers, :date_rappel, :datetime
  end
end
