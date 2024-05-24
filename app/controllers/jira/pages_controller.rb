module Jira
  class PagesController < ApplicationController
    def dashboard
      session[:workspace_id] = params[:workspace_id] if session[:workspace_id] == nil &&  params[:workspace_id].present?
      session[:theme] = params[:theme] if  session[:theme] == nil  &&  params[:theme].present?
      session[:token] = params[:token] if  session[:token] == nil  &&  params[:token].present?
    end
    def privacy; end
  end
end