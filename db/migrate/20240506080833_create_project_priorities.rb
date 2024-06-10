class CreateProjectPriorities < ActiveRecord::Migration[7.1]
  def change
    create_table :cg_project_priorities do |t|
      t.integer :project_id
      t.integer :priority_id
      t.string :title

      t.timestamps
    end
  end
end
