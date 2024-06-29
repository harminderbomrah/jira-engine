module Jira
  class PagesController < ApplicationController
    def dashboard; end

    def home
      if params.key?(:workspace_id) && params.key?(:token) && params.key?(:theme)
        session[:workspace_id] = params[:workspace_id]
        session[:token] = params[:token]
        session[:theme] = params[:theme]
      end
    end

    def privacy; end
  end
end