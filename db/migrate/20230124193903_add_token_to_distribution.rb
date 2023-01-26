class AddTokenToDistribution < ActiveRecord::Migration[7.0]
  def change
    add_column :distributions, :token, :text
  end
end
