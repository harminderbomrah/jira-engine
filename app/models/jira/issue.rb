module Jira
  class Issue < ApplicationRecord
    self.table_name = 'issues'

    belongs_to :project, class_name: 'Jira::Project'
    belongs_to :jira_user, optional: true, class_name: 'Jira::JiraUser'
    belongs_to :code_giant_user, optional: true, class_name: 'Jira::CodeGiantUser'
    has_many :comments, dependent: :destroy, class_name: 'Jira::Comment'
    has_many :histories, dependent: :destroy, class_name: 'Jira::History'
    has_many_attached :attachments, dependent: :purge_later
  end
end