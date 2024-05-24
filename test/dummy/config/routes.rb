Rails.application.routes.draw do
  mount Jira::Engine => "/jira"
end
