class CreateHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :histories do |t|
      t.string :author
      t.datetime :created_at
      t.json :items, null: false, default: {}
      t.references :issue, null: false, foreign_key: true
    end
  end
end
