class CreateUserMappings < ActiveRecord::Migration[7.1]
  def change
    create_table :cg_user_mappings do |t|
      t.integer :jira_user_id, null: false
      t.integer :code_giant_user_id, null: false
      t.integer :project_id, null: false

      t.timestamps
    end

    add_index :cg_user_mappings, [:jira_user_id, :project_id], unique: true
  end
end
