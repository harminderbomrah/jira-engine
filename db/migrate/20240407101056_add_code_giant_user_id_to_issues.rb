class AddCodeGiantUserIdToIssues < ActiveRecord::Migration[7.1]
  def change
    add_column :issues, :code_giant_user_id, :integer
  end
end
