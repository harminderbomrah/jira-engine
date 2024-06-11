class AddCodeGiantUserIdToIssues < ActiveRecord::Migration[7.0]
  def change
    add_column :cg_issues, :code_giant_user_id, :integer
  end
end
