module Jira
  class PagesController < ApplicationController
    def dashboard; end

    def home
      if params.key?(:workspace_id) && params.key?(:token) && params.key?(:theme) && params.key?(:project_type)
        session[:workspace_id] = params[:workspace_id]
        session[:token] = params[:token]
        session[:theme] = params[:theme]
        session[:project_type] = params[:project_type]
        
        redirect_to pages_home_path and return
      end
    end

    def privacy; end
  end
end