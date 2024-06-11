class AddJiraUserIdToIssues < ActiveRecord::Migration[7.0]
  def change
    add_column :cg_issues, :jira_user_id, :integer
  end
end
