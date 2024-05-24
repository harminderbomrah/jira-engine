class AddCodeGiantProjectIdToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :code_giant_project_id, :integer
    add_index :projects, :code_giant_project_id
  end
end
