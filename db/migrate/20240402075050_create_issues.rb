class CreateIssues < ActiveRecord::Migration[7.1]
  def change
    create_table :cg_issues do |t|
      t.string :key
      t.string :summary
      t.text :description
      t.string :status
      t.string :creator_display_name
      t.string :reporter_display_name
      t.datetime :jira_created_at
      t.datetime :jira_updated_at
      t.string :jira_project_id
      t.string :priority
      t.string :issue_type
      t.integer :jira_issue_id, index: { unique: true }
      t.references :cg_projects, null: false, foreign_key: true
      t.timestamps
    end
  end
end
