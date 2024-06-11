class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :cg_comments do |t|
      t.integer :cg_issue_id
      t.string :author
      t.text :body
      t.timestamps
    end

    add_foreign_key :cg_comments, :cg_issues
  end
end
