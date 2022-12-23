class AddCustomerToReservation < ActiveRecord::Migration[7.0]
  def change
    add_reference :reservations, :customer, null: true, foreign_key: true
  end
end
