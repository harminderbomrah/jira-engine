module Jira
  class FetchJiraIssuesJob < ApplicationJob
    queue_as :default

    def perform(current_user, project_id, id, token, workspace_id)
      access_token = current_user&.jira_access_token
      jira_site_id = current_user&.jira_site_id
      jira_service = JiraIssueService.new(access_token, project_id, jira_site_id)
      result = jira_service.fetch_issues
      @issues = result[:issues]
  
      if result[:error].present?
        Rails.logger.error(result[:error])
      elsif @issues.present?
        @issues.each do |issue_data|
          jira_user_data = issue_data[:assignee] # Extracted assignee data from the issue
  
          # Find or create the Jira user
          jira_user = JiraUser.find_by(account_id: jira_user_data[:account_id]) if jira_user_data
  
          # Now create the issue with a reference to the Jira user
          issue = Issue.find_or_create_by!(jira_issue_id: issue_data[:issue_id]) do |issue|
            issue.key = issue_data[:key]
            issue.summary = issue_data[:summary]
            issue.status = issue_data[:status]
            issue.description = issue_data[:description]
            issue.creator_display_name = issue_data[:creator_display_name]
            issue.reporter_display_name = issue_data[:reporter_display_name]
            issue.jira_created_at = issue_data[:created_at]
            issue.jira_updated_at = issue_data[:updated_at]
            issue.priority = issue_data[:priority]
            issue.assignee_name = jira_user_data&.[](:display_name)
            issue.jira_project_id = issue_data[:jira_project_id]
            issue.issue_type = issue_data[:issue_type]
            issue.project_id = id
            issue.jira_user_id = jira_user_data ? jira_user&.id : nil
            issue.due_date = issue_data[:duedate]
            issue.estimated_time = issue_data[:time_estimate]
            issue.actual_time = issue_data[:time_originalestimate]
          end
          # Now fetch comments (histories) for the issue and save them
          save_comments(issue_data[:comments], issue) if issue_data[:comments].present?
          # save_histories(issue_data[:histories], issue) if issue_data[:histories].present?
        end
        Rails.logger.info('Issues fetched successfully.')
        @project = Project.find(id)
        UpdateIssueUserJob.perform_now(@project, @project.user_mappings.all.pluck(:jira_user_id), @project.user_mappings.all.pluck(:code_giant_user_id), token, workspace_id)
        @project.destroy
      else
        Rails.logger.info('No issues found.')
      end
    end
    
    private

    def save_comments(comments_data, issue)
      comments_data['comments'].each do |comment|
        begin
          existing_comment = issue.comments.find_by(id: comment['id'])
  
          if existing_comment
            existing_comment.update(
              author: comment['author']['displayName'],
              body: (comment['body'].is_a?(Hash) ? formatted_body(comment['body']) : comment['body']),
              created_at: comment['created'],
              updated_at: comment['updated']
            )
            puts "Comment with ID #{comment['id']} updated successfully for issue ID #{issue.id}."
          else
            issue.comments.create!(
              issue_id: issue.id,
              id: comment['id'],
              author: comment['author']['displayName'],
              body: (comment['body'].is_a?(Hash) ? formatted_body(comment['body']) : comment['body']),
              created_at: comment['created'],
              updated_at: comment['updated']
            )
            puts "Comment with ID #{comment['id']} created successfully for issue ID #{issue.id}."
          end
        rescue ActiveRecord::RecordNotUnique => e
          puts "Comment with ID #{comment['id']} already exists for issue ID #{issue.id}."
        end
      end
    end
  
    def formatted_body(body)
      body['content']&.map { |c| c['content']&.map { |c| c['text'] }&.join("\n") }&.join("\n\n")
    end
    

    # def save_histories(histories_data, issue)
    #   return unless histories_data && histories_data['values'].present?

    #   histories_data['values'].each do |history_data|
    #     issue.histories.find_or_create_by!(id: history_data['id']) do |history|
    #       history.author = history_data['author']['displayName']
    #       history.created_at = history_data['created']
    #       history.items = history_data['items'].to_json # Serialize items hash to JSON before storing
    #     end
    #   end
    # end
  end
end