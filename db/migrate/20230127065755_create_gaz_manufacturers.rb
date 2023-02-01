class CreateGazManufacturers < ActiveRecord::Migration[7.0]
  def change
    create_table :gaz_manufacturers do |t|
      t.string :name
      t.string :link

      t.timestamps
    end
  end
end
