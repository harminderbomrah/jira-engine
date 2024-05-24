module Jira
  class Project < ApplicationRecord
    self.table_name = 'projects'
    
    validates :user_id, presence: true
    belongs_to :user, class_name: 'Jira::User'
    has_many :issues, dependent: :destroy, class_name: 'Jira::Issue'
    has_one :field_mapping, dependent: :destroy, class_name: 'Jira::FieldMapping'
    has_many :project_statuses, dependent: :destroy, class_name: 'Jira::ProjectStatus'
    has_many :project_priorities, dependent: :destroy, class_name: 'Jira::ProjectPriority'
    has_many :project_types, dependent: :destroy, class_name: 'Jira::ProjectType'
    has_many :user_mappings, dependent: :destroy, class_name: 'Jira::UserMapping'
  end
end