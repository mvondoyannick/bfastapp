class AddLangToSetting < ActiveRecord::Migration[7.0]
  def change
    add_column :settings, :lang, :string
  end
end
