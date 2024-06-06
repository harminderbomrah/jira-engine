module Jira
  class Attachment < ApplicationRecord
    belongs_to :issue, class_name: 'Jira::Issue'
    validates :file_name, presence: true
    validates :link, presence: true
  end
end