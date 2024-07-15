module Jira
  class SessionsController < ApplicationController

    def new; end

    def create
      auth = request.env["omniauth.auth"]
      user = User.find_or_create_by(jira_uid: auth['uid'])
  
      user.update(
        email: auth['info']['email'],
        name: auth['info']['name'],
        jira_access_token: auth['credentials']['token'],
        jira_refresh_token: auth['credentials']['refresh_token'],
        token_expires_at: Time.current + 1.days,
        jira_site_url: auth['extra']['raw_info']['site']['url'],
        jira_site_id: auth['extra']['raw_info']['site']['id']
      )
  
      session[:user_id] = user.id
      redirect_to pages_home_path, notice: 'You have been successfully logged in.'
    end
  
  
  
    def failure
      redirect_to pages_home_path, alert: "Authentication failed, please try again."
    end
  
    def logout
      preserve_session_values
      reset_session
      restore_session_values
    end

    private

    def preserve_session_values
      @workspace_id = session[:workspace_id]
      @token = session[:token]
      @theme = session[:theme]
      @project_type = session[:project_type]
    end

    def restore_session_values
      session[:workspace_id] = @workspace_id
      session[:token] = @token
      session[:theme] = @theme
      session[:project_type] = @project_type
    end
  end
end
