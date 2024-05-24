class CreateProjectStatuses < ActiveRecord::Migration[7.1]
  def change
    create_table :project_statuses do |t|
      t.integer :project_id
      t.integer :status_id
      t.string :title

      t.timestamps
    end
  end
end
