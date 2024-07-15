module Jira
  class ProjectsController < ApplicationController
    before_action :set_project, only: %i[fetch_assignees]
  
    def fetch_latest_projects
      FetchJiraProjectsJob.perform_now(current_jira_user)
      if current_jira_user.projects.present?
        render json: { projects: current_jira_user.projects }, status: :ok
      else
        render json: { error: 'Failed to fetch projects' }, status: :unprocessable_entity
      end
    end
  
    def fetch_assignees
      JiraIssueService.new(current_jira_user.jira_access_token, @project&.project_id, current_jira_user.jira_site_id).fetch_assignees
    end
  
    def edit_importing_project
      @project = Project.find(params[:project_id])
    end
  
    def update_importing_project
      @project = Project.find(params[:project_id])
      @project.update(codegiant_title: params[:codegiant_title], prefix: params[:prefix], project_type: params[:project_type] )
    end
  
    def fetch_codegiant_users
      FetchCodegiantUsersJob.perform_now(session[:token])
      @jira_users = JiraUser.all
      @code_giant_users = CodeGiantUser.all
      respond_to do |format|
        format.json { render json: { jira_users: @jira_users, code_giant_users: @code_giant_users } }
      end
    end
  
    def update_issue_user
      project_id = params[:project_id]
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
        @project = Project.find_by(id: params[:project_id])
        FetchJiraIssuesJob.perform_later(current_jira_user, @project&.project_id, project_id, session[:token], session[:workspace_id])
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
  
    def check_authentication
      if session[:user_id]
        render json: { authenticated: true }, status: :ok
      else
        render json: { authenticated: false }, status: :unauthorized
      end
    end
  
    private
  
    def set_project
      @project = current_jira_user.projects.find(params[:id])
    end
  end
end