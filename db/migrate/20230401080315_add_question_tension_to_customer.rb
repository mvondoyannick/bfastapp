class AddQuestionTensionToCustomer < ActiveRecord::Migration[7.0]
  def change
    add_column :customers, :question_tension, :string
  end
end
