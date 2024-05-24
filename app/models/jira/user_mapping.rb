module Jira
  class UserMapping < ApplicationRecord
    self.table_name = 'user_mappings'
    
    belongs_to :project, class_name: 'Jira::Project'
  end
end