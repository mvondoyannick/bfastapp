class CreateHoraires < ActiveRecord::Migration[7.0]
  def change
    create_table :horaires do |t|
      t.string :name
      t.string :depart

      t.timestamps
    end
  end
end
