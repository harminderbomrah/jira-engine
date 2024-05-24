# app/models/project_status.rb
module Jira
  class ProjectStatus < ApplicationRecord
    self.table_name = 'project_statuses'

    belongs_to :project, class_name: 'Jira::Project'
  end
end