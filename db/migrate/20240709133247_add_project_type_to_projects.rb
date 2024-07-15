class AddProjectTypeToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :cg_projects, :project_type, :string
  end
end
