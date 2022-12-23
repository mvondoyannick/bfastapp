class CreateTravelTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :travel_transactions do |t|
      t.string :amount
      t.string :reference
      t.string :tstatus
      t.string :currency
      t.string :operator
      t.string :code
      t.string :external_reference

      t.timestamps
    end
  end
end
