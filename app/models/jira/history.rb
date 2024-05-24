module Jira
  # app/models/history.rb
    class History < ApplicationRecord
      self.table_name = 'histories'
  
      belongs_to :issue, class_name: 'Jira::Issue'
    end
  end