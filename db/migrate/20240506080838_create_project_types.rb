class CreateProjectTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :cg_project_types do |t|
      t.integer :project_id
      t.integer :type_id
      t.string :title
      t.string :color
      t.boolean :complete_trigger

      t.timestamps
    end
  end
end
