module Jira
  class User < ApplicationRecord
    self.table_name = 'cg_users'
    
    validates :email, presence: true, uniqueness: true
    validates :jira_uid, uniqueness: true
    has_many :projects, dependent: :destroy, class_name: 'Jira::Project', foreign_key: 'cg_users_id'
    has_many :issues, through: :projects, class_name: 'Jira::Issue'
  end
end