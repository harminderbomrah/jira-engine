class AddCodeGiantTaskIdToIssues < ActiveRecord::Migration[7.0]
  def change
    add_column :cg_issues, :code_giant_task_id, :integer
    add_index :cg_issues, :code_giant_task_id
  end
end
