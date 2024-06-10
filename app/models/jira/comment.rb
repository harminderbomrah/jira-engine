# app/models/comment.rb
module Jira
  class Comment < ApplicationRecord
    self.table_name = 'cg_comments'

    belongs_to :issue, class_name: 'Jira::Issue', foreign_key: 'cg_issue_id'
  end
end