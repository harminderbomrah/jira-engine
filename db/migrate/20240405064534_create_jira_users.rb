class CreateJiraUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :cg_jira_users do |t|
      t.string :account_id
      t.string :display_name
      t.string :avatar_url

      t.timestamps
    end
  end
end
