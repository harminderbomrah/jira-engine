class AddPrefixAndCodegiantTitleToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :prefix, :string
    add_column :projects, :codegiant_title, :string
  end
end
