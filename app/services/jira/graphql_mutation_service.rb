require 'httparty'
module Jira
  class GraphqlMutationService
    include HTTParty
    base_uri ENV['BASE_URL']
  
    def initialize(token)
      @headers = {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{token}"
      }
    end
  
    def create_project(workspace_id:, project_type:, tracking_type:, prefix:, title:)
      query = <<~GRAPHQL
        mutation createProject($workspaceId: ID!, $projectType: String!, $trackingType: String!, $prefix: String!, $title: String!) {
          createProject(workspaceId: $workspaceId, projectType: $projectType, trackingType: $trackingType, prefix: $prefix, title: $title) {
            id
            title
            taskPriorities{
              id
              title
            }
            taskStatuses{
              id
              title
            }
            taskTypes{
              id
              title
              color
              completeTrigger
            }
          }
        }
      GRAPHQL
      variables = { workspaceId: workspace_id, projectType: project_type, trackingType: tracking_type, prefix: prefix, title: title }
      execute_query(query, variables)
    end
  
    def create_project_task(project_id:, title:, description:, status_id:, priority_id:, type_id:, estimated_time:, actual_time:, start_date:, due_date:)    query = <<~GRAPHQL
      mutation createProjectTask($projectId: ID!, $title: String!, $description: String!, $statusId: ID, $priorityId: ID, $typeId: ID, $estimatedTime: Float!, $actualTime: Float!, $startDate: String, $dueDate: String) {
        createProjectTask(projectId: $projectId, title: $title, description: $description, statusId: $statusId, priorityId: $priorityId, typeId: $typeId, estimatedTime: $estimatedTime, actualTime: $actualTime, startDate: $startDate, dueDate: $dueDate) {
            id
            title
          }
        }
      GRAPHQL
  
      variables = {
        projectId: project_id,
        title: title,
        description: description,
        statusId: status_id,
        priorityId: priority_id,
        typeId: type_id,
        estimatedTime: estimated_time,
        actualTime: actual_time,
        startDate: start_date,
        dueDate: due_date
      }
  
      execute_query(query, variables)
    end
  
    def update_project_task(id:, assigned_user_id:)
      query = <<~GRAPHQL
        mutation updateProjectTask($id: ID!, $assignedUserId: ID) {
          updateProjectTask(id: $id, assignedUserId: $assignedUserId) {
            id
            title
          }
        }
      GRAPHQL
      variables = { id: id, assignedUserId: assigned_user_id }
      execute_query(query, variables)
    end
  
    def create_project_comment(task_id:, content:)
      query = <<~GRAPHQL
        mutation createProjectComment($taskId: ID!, $content: String!) {
          createProjectComment(taskId: $taskId, content: $content) {
            id
            # Other fields you may want to retrieve after creating the comment
          }
        }
      GRAPHQL
      variables = { taskId: task_id, content: content }
      execute_query(query, variables)
    end
  
    def update_project_labels(workspace_id:, id:, type_id:, labels:)
      query = <<~GRAPHQL
        mutation updateProjectLabels($workspaceId: ID!, $id: ID!, $typeId: Int!, $labels: [ProjectLabelsInput!]!) {
          updateProjectLabels(workspaceId: $workspaceId, id: $id, typeId: $typeId, labels: $labels) {
            id
            title
            color
            completeTrigger
          }
        }
      GRAPHQL
  
      variables = {
        workspaceId: workspace_id,
        id: id,
        typeId: type_id,
        labels: labels
      }
  
      execute_query(query, variables)
    end
  
    def upload_project_file(task_id, file_path, file_name, file_size, token)
      @task_id = task_id
      @file_path = file_path
      @file_name = file_name
      @file_size = file_size
      @url = URI("#{ENV['BASE_URL']}")
      @auth_token =  token # It's better to store this in environment variables
      https = Net::HTTP.new(@url.host, @url.port)
      https.use_ssl = true
  
      request = Net::HTTP::Post.new(@url)
      request["Authorization"] = "Bearer #{@auth_token}"
  
      form_data = [
        ['operations', operations_payload],
        ['map', '{"0": ["variables.attachment"]}'],
        ['0', File.open(@file_path)]
      ]
  
      request.set_form form_data, 'multipart/form-data'
  
      response = https.request(request)
      parse_response(response)
    end
  
    private
  
    def execute_query(query, variables = {})
      response = self.class.post("/", {
        body: { query: query, variables: variables }.to_json,
        headers: @headers
      })
  
      # Check if the response was successful and contains data
      if response.success?
        if response.parsed_response["errors"]
          # If there are GraphQL errors, return them
          { "errors" => response.parsed_response["errors"].map { |e| e["message"] }.join(", ") }
        else
          response.parsed_response["data"]
        end
      else
        # Handle HTTP errors
        { "errors" => "HTTP Error: #{response.code}" }
      end
  
      rescue HTTParty::Error => e
        { "errors" => "HTTParty Error: #{e.message}" }
      rescue StandardError => e
        { "errors" => "Standard Error: #{e.message}" }
    end
  
    def operations_payload
      {
        query: <<~GRAPHQL,
          mutation UploadProjectFile($taskId: ID!, $fileName: String!, $fileSize: Int!, $attachment: Upload!) {
            uploadProjectFile(taskId: $taskId, fileName: $fileName, fileSize: $fileSize, attachment: $attachment) {
              id
              fileName
              fileSize
              attachmentUrl
            }
          }
        GRAPHQL
        variables: {
          taskId: @task_id,
          fileName: @file_name,
          fileSize: @file_size,
          attachment: nil
        }
      }.to_json
    end
  
    def parse_response(response)
      body = JSON.parse(response.body)
      if response.is_a?(Net::HTTPSuccess)
        body["data"]["uploadProjectFile"]
      else
        body["errors"] || "An error occurred"
      end
    end
  end
end