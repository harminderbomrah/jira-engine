module Jira
  class FieldMapping < ApplicationRecord
    self.table_name = 'cg_field_mappings'

    belongs_to :project, class_name: 'Jira::Project', foreign_key: 'cg_projects_id'
  end
end