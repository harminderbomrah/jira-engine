class AddJiraSiteIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :jira_site_id, :string
  end
end
