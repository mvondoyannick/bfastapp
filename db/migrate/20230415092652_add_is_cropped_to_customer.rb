class AddIsCroppedToCustomer < ActiveRecord::Migration[7.0]
  def change
    add_column :customers, :is_cropped, :boolean
  end
end
