class CreateProjects < ActiveRecord::Migration[7.1]
  def change
    create_table :projects do |t|
      t.string :project_id
      t.string :project_key
      t.string :name
      t.string :url

      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
