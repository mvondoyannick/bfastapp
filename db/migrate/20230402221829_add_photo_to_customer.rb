class AddPhotoToCustomer < ActiveRecord::Migration[7.0]
  def change
    add_column :customers, :photo, :string
    add_column :customers, :photo_type, :string
  end
end
