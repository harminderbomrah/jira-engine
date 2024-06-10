# app/models/project_type.rb
module Jira
  class ProjectType < ApplicationRecord
    self.table_name = 'cg_project_types'

    belongs_to :project, class_name: 'Jira::Project'
  end
end