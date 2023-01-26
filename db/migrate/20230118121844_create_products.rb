class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :amount
      t.references :category, null: false, foreign_key: true
      t.boolean :promotion
      t.string :promotion_amount
      t.datetime :promotion_begin
      t.datetime :promotion_end

      t.timestamps
    end
  end
end
