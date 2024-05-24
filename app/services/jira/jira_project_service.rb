require 'rest-client'
require 'json'
module Jira
  class JiraProjectService
    def self.fetch_projects(access_token, jira_site_id)
      # Define the API endpoint for retrieving projects
      projects_endpoint = "https://api.atlassian.com/ex/jira/#{jira_site_id}/rest/api/3/project"
  
      begin
        # Make a GET request to the projects endpoint with the access token
        response = RestClient.get(projects_endpoint, { Authorization: "Bearer #{access_token}" })
        # Parse the response JSON
        projects = JSON.parse(response.body)
  
        # Check if the response contains projects
        if projects.is_a?(Array) && !projects.empty?
          puts 'Projects retrieved successfully:'
          projects.each do |project|
            puts "#{project['key']} - #{project['name']}"
          end
        else
          puts 'No projects found.'
        end
      rescue RestClient::ExceptionWithResponse => e
        # Handle any errors returned by the API
        response = JSON.parse(e.response)
      rescue StandardError => e
        # Handle any other unexpected errors
        puts "Error: #{e.message}"
      end
    end
  end
end