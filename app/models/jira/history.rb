module Jira
  # app/models/history.rb
    class History < ApplicationRecord
      self.table_name = 'cg_histories'
  
      belongs_to :issue, class_name: 'Jira::Issue', foreign_key: 'cg_issues_id'
    end
  end