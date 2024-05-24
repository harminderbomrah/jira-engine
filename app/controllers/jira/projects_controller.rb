module Jira
  class ProjectsController < ApplicationController
    before_action :authenticate_user!, only: %i[index fetch_latest_projects]
    before_action :set_project, only: %i[show update_issue_user update_and_fetch fetch_assignees]
    skip_before_action :verify_authenticity_token, only: %i[update_importing_project fetch_codegiant_users fetch_assignees]
    after_action :update_and_fetch, only: %i[update_issue_user]
    def index
      @projects = current_user.projects.all
    end
  
    def show
    end
  
    def fetch_latest_projects
      flash_message = FetchJiraProjectsJob.perform_now(current_user)
      flash[:notice] = flash_message if flash_message.present?
      redirect_to projects_path
    end
  
    def fetch_assignees
      JiraIssueService.new(current_user.jira_access_token, @project&.project_id, current_user.jira_site_id).fetch_assignees
      return :ok
    end
  
    def edit_importing_project
      @project = Project.find(params[:project_id])
    end
  
    def update_importing_project
      @project = Project.find(params[:project][:project_id])
      @project.update(codegiant_title: params[:project][:codegiant_title], prefix: params[:project][:prefix])
      flash[:notice] = 'Project was updated successfully.'
      redirect_to @project
    end
  
    def fetch_codegiant_users
      FetchCodegiantUsersJob.perform_now()
    end
  
    def codegiant_users_page
      @jira_users = JiraUser.all
      @code_giant_users = CodeGiantUser.all
    end
  
    def update_issue_user
      project_id = params[:id]
      jira_user_ids = params[:jira_user_ids]
      code_giant_user_ids = params[:code_giant_user_ids]
  
      if jira_user_ids.present?
        # Iterate through jira_user_ids array and update/create records
        jira_user_ids.each_with_index do |jira_user_id, index|
          code_giant_user_id = code_giant_user_ids[index]
  
          # Proceed only if both IDs are present
          if jira_user_id.present? && code_giant_user_id.present?
            # Find or create user mapping record
            user_mapping = UserMapping.find_or_initialize_by(jira_user_id: jira_user_id, project_id: project_id)
            user_mapping.update(code_giant_user_id: code_giant_user_id)
          end
        end
  
        flash[:success] = "User mappings updated successfully."
      else
        flash[:error] = "No user mappings provided."
      end
  
      redirect_to pages_home_path 
    end
  
    def destroy
      @project = Project.find(params[:id])
      @project.destroy
      flash[:notice] = 'Project was successfully deleted.'
      redirect_to projects_path
    end
  
    def update_and_fetch
      FetchJiraIssuesJob.perform_later(current_user, @project&.project_id, params[:id], session[:token], session[:workspace_id])
    end
  
    private
  
    def authenticate_user!
      unless session[:user_id]
        flash[:alert] = "You must be logged in to access this page."
        redirect_to import_jira_path
      end
    end
  
    def set_project
      @project = current_user.projects.find(params[:id])
    end
  end
end