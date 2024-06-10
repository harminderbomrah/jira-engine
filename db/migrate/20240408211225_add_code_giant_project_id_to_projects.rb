class AddCodeGiantProjectIdToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :cg_projects, :code_giant_project_id, :integer
    add_index :cg_projects, :code_giant_project_id
  end
end
