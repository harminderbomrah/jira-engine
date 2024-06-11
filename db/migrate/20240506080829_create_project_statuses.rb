class CreateProjectStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :cg_project_statuses do |t|
      t.integer :project_id
      t.integer :status_id
      t.string :title

      t.timestamps
    end
  end
end
