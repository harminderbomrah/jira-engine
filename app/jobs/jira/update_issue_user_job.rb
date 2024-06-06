module Jira
  class UpdateIssueUserJob < ApplicationJob
    queue_as :default
  
    def perform(project, jira_user_ids, code_giant_user_ids, token, work_space_id)
      graphql_service = GraphqlMutationService.new(token)
      id_to_graphql_id_mapping = CodeGiantUser.where(id: code_giant_user_ids).pluck(:id, :graphql_id).to_h
  
      unless project.code_giant_project_id.present?
        project_info = {
          workspace_id: work_space_id,
          project_type: "scrum",
          tracking_type: "time",
          prefix: project.prefix,
          title: project.codegiant_title
        }
  
        project_response = graphql_service.create_project(**project_info)
  
        if project_response.dig("createProject", "id")
          created_project_id = project_response["createProject"]["id"]
          project.update(code_giant_project_id: created_project_id)
          # Create project statuses for the project using the statuses returned in the mutation response
          project_statuses = project_response.dig("createProject", "taskStatuses")
          if project_statuses.present?
            project_statuses&.each do |status|
              ProjectStatus.find_or_create_by(project_id: project.id, status_id: status["id"]) do |project_status|
                project_status.title = status["title"]
              end
            end
          end
  
          project_priorities = project_response.dig("createProject", "taskPriorities")
          if project_priorities.present?
            project_priorities&.each do |priority|
              ProjectPriority.find_or_create_by(project_id: project.id, priority_id: priority["id"]) do |project_priority|
                project_priority.title = priority["title"]
              end
            end
          end
  
          project_types = project_response.dig("createProject", "taskTypes")
          if project_types.present?
            project_types&.each do |type|
              ProjectType.find_or_create_by(project_id: project.id, type_id: type["id"]) do |project_type|
                project_type.title = type["title"]
                project_type.color = type["color"]
                project_type.complete_trigger = type["completeTrigger"]
              end
            end
          end
        elsif project_response["errors"]
          error_messages = if project_response["errors"].is_a?(Array)
                              project_response["errors"].map { |error| error["message"] }.join(", ")
                            else
                              project_response["errors"].to_s
                            end
          Rails.logger.error "Failed to create project in CodeGiant: #{error_messages}"
          return
        else
          Rails.logger.error "Failed to create project in CodeGiant for an unknown reason."
          return
        end
      else
        created_project_id = project.code_giant_project_id
      end
      
      update_project_labels(project, graphql_service, work_space_id)
  
      field_mappings = project&.field_mapping
      Issue.transaction do
        if jira_user_ids.present?
          jira_user_ids.zip(code_giant_user_ids).each do |jira_user_id, code_giant_user_id|
            display_name = JiraUser.find(jira_user_id).display_name
            issues = project.issues.where(assignee_name: display_name).or(project.issues.where(assignee_name: nil))
            
            issues.each do |issue|
              process_issue(issue, project, created_project_id, field_mappings, graphql_service, id_to_graphql_id_mapping, code_giant_user_id)
            end
          end
        else
          issues = project.issues.where(assignee_name: nil)
  
          issues.each do |issue|
            process_issue(issue, project, created_project_id, field_mappings, graphql_service, id_to_graphql_id_mapping, nil)
          end
        end
      end
      Rails.logger.info "Tasks created and user mapping updated successfully."
    end
  
    private
  
    def create_comments_for_issue(issue, graphql_service, created_task_id)
      issue&.comments.each do |comment|
        comment_info = {
          task_id: created_task_id,
          content: comment&.body
        }
        comment_response = graphql_service.create_project_comment(**comment_info)
  
        if comment_response["createProjectComment"] && comment_response["createProjectComment"]["id"]
          Rails.logger.info "Comment created successfully for task #{created_task_id}"
        else
          Rails.logger.error "Failed to create comment for task #{created_task_id}"
        end
      end
    end
  
    def update_project_labels(project, graphql_service, work_space_id)
      workspace_id = work_space_id
      type_id = 2
      project_types = project.project_types
      jira_aditional_types = ["Epic", "Change Request", "Task"] - project_types&.pluck(:title).uniq
      labels = []
      project_types.each do |type|
        labels << { id: type&.type_id&.to_s, title: type.title, color: type.color, completeTrigger: type.complete_trigger }
      end
      jira_aditional_types.each do |type|
        labels << { id: nil, title: type, color: "#500000", completeTrigger: false }
      end
      response = graphql_service.update_project_labels(workspace_id: workspace_id, id: project.code_giant_project_id, type_id: type_id, labels: labels)
      if response["errors"]
        Rails.logger.error "Failed to update project labels: #{response["errors"]}"
      else
        response_project_types = response["updateProjectLabels"]
        response_project_types.each do |type|
          ProjectType.find_or_create_by(project_id: project.id, title: type["title"]) do |project_type|
            project_type.type_id = type["id"]
            project_type.color = type["color"]
            project_type.complete_trigger = type["completeTrigger"]
          end
        end
        Rails.logger.info "Project labels updated successfully"
      end
    end
  
    def process_issue(issue, project, created_project_id, field_mappings, graphql_service, id_to_graphql_id_mapping, code_giant_user_id)
      status_mapping = {
        "To Do" => "open",
        "Open" => "open",
        "In Progress" => "in progress",
        "Done" => "complete"
      }
  
      mapped_status = status_mapping[issue&.status]
      status_id = project.project_statuses.find_by("LOWER(title) = ?", mapped_status)&.status_id if mapped_status
  
      type_mapping = {
        "Story" => "story",
        "Bug" => "bug",
        "Sub-task" => "subtask",
        "New Feature" => "feature"
      }
  
      mapped_type = type_mapping[issue&.issue_type] || issue&.issue_type
      type_id = project.project_types.find_by("LOWER(title) = ?", mapped_type)&.type_id if mapped_type
  
      priority_mapping = {
        "Lowest" => "trivial",
        "Low" => "trivial",
        "Medium" => "minor",
        "High" => "critical",
        "Highest" => "critical"
      }
  
      mapped_priority = priority_mapping[issue&.priority]
      priority_id = project.project_priorities.find_by("LOWER(title) = ?", mapped_priority)&.priority_id if mapped_priority
  
      code_giant_user_id_to_use = issue.jira_user_id.nil? ? nil : code_giant_user_id
      issue.update(code_giant_user_id: code_giant_user_id_to_use)
  
      if issue.code_giant_task_id.blank?
        task_info = {
          project_id: created_project_id,
          title: issue.public_send(field_mappings&.mapping&.fetch('Title', :summary) || :summary),
          estimated_time: issue.public_send(field_mappings&.mapping&.fetch('Estimated Time', :estimated_time) || :estimated_time).to_f / 3600,
          actual_time: issue.public_send(field_mappings&.mapping&.fetch('Actual Time', :actual_time) || :actual_time).to_f / 3600,
          start_date: issue.public_send(field_mappings&.mapping&.fetch('Start Date', :jira_created_at) || :jira_created_at),
          due_date: issue.public_send(field_mappings&.mapping&.fetch('Due Date', :due_date) || :due_date),
          status_id: status_id,
          priority_id: priority_id,
          type_id: type_id
        }
  
        description_fields = field_mappings&.mapping&.fetch('Description', [:description])
        description_values = description_fields&.map do |field|
          value = issue.public_send(field)
          "#{field}: #{value}" unless value.blank?
        end.compact&.join("\n")
  
        task_info[:description] = description_values || ''
  
        task_response = graphql_service.create_project_task(**task_info)
  
        if task_response["createProjectTask"] && task_response["createProjectTask"]["id"]
          created_task_id = task_response["createProjectTask"]["id"]
          issue.update(code_giant_task_id: created_task_id)
          issue.attachments.each do |attachment|
            graphql_service.upload_project_file(
              issue&.code_giant_task_id, # Assuming this is the task ID where the file needs to be attached
              ActiveStorage::Blob.service.path_for(attachment.key),
              attachment&.blob&.filename.to_s,
              attachment&.blob&.byte_size
            )
          end
          create_comments_for_issue(issue, graphql_service, created_task_id)
        else
          Rails.logger.error "Failed to create task for issue #{issue.id} in CodeGiant"
        end
      end
  
      if issue.code_giant_task_id.present? && !code_giant_user_id_to_use.nil?
        code_giant_user_graphql_id = id_to_graphql_id_mapping[code_giant_user_id_to_use.to_i]
  
        task_update_info = {
          id: issue.code_giant_task_id,
          assigned_user_id: code_giant_user_graphql_id
        }
        update_response = graphql_service.update_project_task(**task_update_info)
        unless update_response.dig("updateProjectTask", "id")
          Rails.logger.error "Failed to update task #{issue.code_giant_task_id} in CodeGiant"
        end
      end
    end
  end
end