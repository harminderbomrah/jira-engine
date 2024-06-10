module Jira
  class Issue < ApplicationRecord
    self.table_name = 'cg_issues'

    belongs_to :project, class_name: 'Jira::Project', foreign_key: 'cg_projects_id'
    belongs_to :jira_user, optional: true, class_name: 'Jira::JiraUser'
    belongs_to :code_giant_user, optional: true, class_name: 'Jira::CodeGiantUser'
    has_many :comments, dependent: :destroy, class_name: 'Jira::Comment', foreign_key: 'cg_issue_id'
    has_many :histories, dependent: :destroy, class_name: 'Jira::History', foreign_key: 'cg_issues_id'
    has_many_attached :attachments, dependent: :purge_later
  end
end