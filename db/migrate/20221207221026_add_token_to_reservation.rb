class AddTokenToReservation < ActiveRecord::Migration[7.0]
  def change
    add_column :reservations, :token, :string
  end
end
