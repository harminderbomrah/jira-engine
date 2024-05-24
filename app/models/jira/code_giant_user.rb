module Jira
  class CodeGiantUser < ApplicationRecord
    self.table_name = 'code_giant_users'

    has_many :issues, dependent: :nullify, class_name: 'Jira::Issue'
  end
end