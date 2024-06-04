module Jira
  class FetchJiraProjectsJob < ApplicationJob
    queue_as :default
  
    def perform(current_user)
      access_token = current_user&.jira_access_token
      jira_site_id = current_user&.jira_site_id
      response = JiraProjectService.fetch_projects(access_token, jira_site_id)
  
      if response.present?
        if response.is_a?(Hash) && response['code'] == 401
          Rails.logger.error "Unauthorized: #{response['message']}"
        elsif response.any? { |project| project.is_a?(Hash) && project['key'].present? }
          response.each do |project_data|
            project = current_user.projects.find_or_initialize_by(project_id: project_data['id'])
            project.update(
              project_key: project_data['key'],
              name: project_data['name'],
              url: project_data['self'],
              user_id: current_user.id
            )
          end
          Rails.logger.info "Latest projects fetched successfully."
        else
          error_message = response.nil? ? "No projects found." : response[:error_messages].join(', ')
          Rails.logger.warn "Failed to fetch latest projects: #{error_message}"
        end
      end
    end
  end
end