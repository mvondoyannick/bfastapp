class CreateVilles < ActiveRecord::Migration[7.0]
  def change
    create_table :villes do |t|
      t.string :name
      t.string :code
      t.string :token

      t.timestamps
    end
  end
end
