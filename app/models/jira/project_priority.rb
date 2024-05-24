# app/models/project_priority.rb
module Jira
  class ProjectPriority < ApplicationRecord
    self.table_name = 'project_priorities'

    belongs_to :project, class_name: 'Jira::Project'
  end
end