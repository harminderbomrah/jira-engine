class AddPrefixAndCodegiantTitleToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :cg_projects, :prefix, :string
    add_column :cg_projects, :codegiant_title, :string
  end
end
