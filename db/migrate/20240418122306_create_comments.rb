class CreateComments < ActiveRecord::Migration[7.1]
  def change
    create_table :comments do |t|
      t.integer :issue_id
      t.string :author
      t.text :body
      t.timestamps
    end

    add_foreign_key :comments, :issues
  end
end
