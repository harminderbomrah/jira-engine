class CreateHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :cg_histories do |t|
      t.string :author
      t.datetime :created_at
      t.json :items, null: false, default: {}
      t.references :cg_issues, null: false, foreign_key: true
    end
  end
end
