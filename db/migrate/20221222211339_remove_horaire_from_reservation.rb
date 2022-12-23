class RemoveHoraireFromReservation < ActiveRecord::Migration[7.0]
  def change
    remove_reference :reservations, :horaire, null: true, foreign_key: true
  end
end
