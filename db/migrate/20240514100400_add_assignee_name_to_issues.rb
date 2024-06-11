class AddAssigneeNameToIssues < ActiveRecord::Migration[7.0]
  def change
    add_column :cg_issues, :assignee_name, :string
  end
end
