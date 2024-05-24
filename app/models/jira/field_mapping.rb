module Jira
  class FieldMapping < ApplicationRecord
    self.table_name = 'field_mappings'

    belongs_to :project, class_name: 'Jira::Project'
  end
end