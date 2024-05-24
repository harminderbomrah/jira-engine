class AddCodeGiantTaskIdToIssues < ActiveRecord::Migration[7.1]
  def change
    add_column :issues, :code_giant_task_id, :integer
    add_index :issues, :code_giant_task_id
  end
end
