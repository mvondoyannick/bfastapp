class AddResumeToVille < ActiveRecord::Migration[7.0]
  def change
    add_column :villes, :resume, :text
  end
end
