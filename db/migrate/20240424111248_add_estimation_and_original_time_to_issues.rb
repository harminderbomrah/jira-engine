class AddEstimationAndOriginalTimeToIssues < ActiveRecord::Migration[7.1]
  def change
    add_column :cg_issues, :estimated_time, :integer
    add_column :cg_issues, :actual_time, :integer
    add_column :cg_issues, :due_date, :datetime
  end
end
