class AddDepartToReservation < ActiveRecord::Migration[7.0]
  def change
    add_column :reservations, :depart, :string
    add_column :reservations, :arrivee, :string
    add_column :reservations, :date_depart, :string
    add_column :reservations, :heure, :string
    add_column :reservations, :customer_phone_payment, :string
    add_column :reservations, :amount, :string
    add_column :reservations, :paid, :boolean
    add_column :reservations, :fee, :string
  end
end
