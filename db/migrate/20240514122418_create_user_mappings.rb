class CreateUserMappings < ActiveRecord::Migration[7.1]
  def change
    create_table :user_mappings do |t|
      t.integer :jira_user_id, null: false
      t.integer :code_giant_user_id, null: false
      t.integer :project_id, null: false

      t.timestamps
    end

    add_index :user_mappings, [:jira_user_id, :project_id], unique: true
  end
end
