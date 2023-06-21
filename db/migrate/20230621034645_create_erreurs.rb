class CreateErreurs < ActiveRecord::Migration[7.0]
  def change
    create_table :erreurs do |t|
      t.string :description
      t.references :customer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
