class AddEstimationAndOriginalTimeToIssues < ActiveRecord::Migration[7.1]
  def change
    add_column :issues, :estimated_time, :integer
    add_column :issues, :actual_time, :integer
    add_column :issues, :due_date, :datetime
  end
end
