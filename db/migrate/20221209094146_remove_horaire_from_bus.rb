class RemoveHoraireFromBus < ActiveRecord::Migration[7.0]
  def change
    remove_reference :buses, :horaire, null: true, foreign_key: true
  end
end
