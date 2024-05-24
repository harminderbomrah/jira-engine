class AddJiraUserIdToIssues < ActiveRecord::Migration[7.1]
  def change
    add_column :issues, :jira_user_id, :integer
  end
end
