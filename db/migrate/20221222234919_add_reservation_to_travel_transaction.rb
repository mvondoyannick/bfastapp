class AddReservationToTravelTransaction < ActiveRecord::Migration[7.0]
  def change
    add_reference :travel_transactions, :reservation, null: true, foreign_key: true
  end
end
