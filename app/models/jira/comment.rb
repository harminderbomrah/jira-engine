# app/models/comment.rb
module Jira
  class Comment < ApplicationRecord
    self.table_name = 'comments'

    belongs_to :issue, class_name: 'Jira::Issue'
  end
end