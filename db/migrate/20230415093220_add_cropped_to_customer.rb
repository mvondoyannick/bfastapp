class AddCroppedToCustomer < ActiveRecord::Migration[7.0]
  def change
    add_column :customers, :cropped, :string
  end
end
