module Jira
  class JiraUser < ApplicationRecord
    self.table_name = 'jira_users'
    
    has_many :issues, dependent: :nullify, class_name: 'Jira::Issue'
  end
end