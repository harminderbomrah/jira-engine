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
        token_expires_at: Time.at(auth['credentials']['expires_at']).to_datetime,
        jira_site_url: auth['extra']['raw_info']['site']['url'],
        jira_site_id: auth['extra']['raw_info']['site']['id']
      )
  
      session[:user_id] = user.id
      redirect_to pages_home_path, notice: 'You have been successfully logged in.'
    end
  
  
  
    def failure
      redirect_to import_jira_path, alert: "Authentication failed, please try again."
    end
  
    def logout
      reset_session
      redirect_to import_jira_path, notice: 'You have been successfully logged out.'
    end
  end
end
