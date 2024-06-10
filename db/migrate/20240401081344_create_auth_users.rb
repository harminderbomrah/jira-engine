class CreateAuthUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :cg_users do |t|
      t.string :email
      t.string :name
      t.string :jira_uid
      t.string :jira_access_token
      t.string :jira_refresh_token
      t.datetime :token_expires_at
      t.string :jira_site_url

      t.timestamps
    end
  end
end
