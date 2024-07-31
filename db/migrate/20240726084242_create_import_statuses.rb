class CreateImportStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :cg_import_statuses do |t|
      t.integer :userid
      t.string :status
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end
  end
end
