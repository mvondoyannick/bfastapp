class CreateParametres < ActiveRecord::Migration[7.0]
  def change
    create_table :parametres do |t|
      t.string :tension_droite
      t.string :tension_gauche
      t.string :quartier
      t.string :steps
      t.string :code
      t.string :diastole_droit
      t.string :diastole_gauche
      t.string :poul_droit
      t.string :poul_gauche
      t.string :linked
      t.string :question_tension
      t.string :rappel
      t.string :rappel_day
      t.string :date_rappel
      t.string :photo
      t.string :photo_type
      t.boolean :is_cropped
      t.string :cropped
      t.string :poids
      t.string :taille

      t.timestamps
    end
  end
end
