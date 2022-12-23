class RemoveBusFromReservation < ActiveRecord::Migration[7.0]
  def change
    remove_reference :reservations, :bus, null: true, foreign_key: true
    remove_reference :reservations, :ville, null: true, foreign_key: true
  end
end
