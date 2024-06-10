class AddAssigneeNameToIssues < ActiveRecord::Migration[7.1]
  def change
    add_column :cg_issues, :assignee_name, :string
  end
end
