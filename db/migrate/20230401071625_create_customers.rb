class CreateCustomers < ActiveRecord::Migration[7.0]
  def change
    create_table :customers do |t|
      t.string :pushname
      t.string :phone
      t.string :ip
      t.string :sexe
      t.string :age
      t.string :tension_gauche
      t.string :tension_droit
      t.string :quartier
      t.string :link
      t.string :steps
      t.string :real_name
      t.string :code
      t.string :diastole_droit
      t.string :diastole_gauche
      t.string :poul_droit
      t.string :poul_gauche
      t.string :linked

      t.timestamps
    end
  end
end
