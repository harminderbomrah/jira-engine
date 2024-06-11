module Jira
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    helper_method :current_jira_user

    private
    def current_jira_user
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end
  end
end
