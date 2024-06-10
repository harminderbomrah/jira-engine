class CreateProjects < ActiveRecord::Migration[7.1]
  def change
    create_table :cg_projects do |t|
      t.string :project_id
      t.string :project_key
      t.string :name
      t.string :url

      t.references :cg_users, foreign_key: true

      t.timestamps
    end
  end
end
