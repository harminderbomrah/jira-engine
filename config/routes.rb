Jira::Engine.routes.draw do
  get '/pages/home', to: 'pages#home'
  get 'check_authentication', to: 'projects#check_authentication'
  get '/auth/:provider/callback', to: 'sessions#create'
  delete '/logout', to: 'sessions#logout', as: 'logout'
  resources :projects do
    post 'fetch_assignees', on: :member
    collection do
      post 'fetch_latest_projects', to: 'projects#fetch_latest_projects'
    end
  end
  get '/privacy', to: 'pages#privacy'
  post 'fetch_codegiant_users', to: 'projects#fetch_codegiant_users'
  post 'update_issue_user', to: 'projects#update_issue_user'
  resources :field_mappings, only: [:new, :create]
  get 'edit_importing_project/:project_id', to: 'projects#edit_importing_project', as: 'edit_importing_project'
  patch 'update_importing_project', to: 'projects#update_importing_project', as: 'update_importing_project'
end
