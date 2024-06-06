module Jira
  class FetchJiraIssuesJob < ApplicationJob
    queue_as :default
    MAX_RETRIES = 3
  
    def perform(current_user, project_id, id, token, workspace_id)
      access_token = current_user&.jira_access_token
      jira_site_id = current_user&.jira_site_id
      jira_service = JiraIssueService.new(access_token, project_id, jira_site_id)
  
      retries = 0
  
      begin
        result = jira_service.fetch_issues
        @issues = result[:issues]
  
        if result[:error].present?
          Rails.logger.error(result[:error])
        elsif @issues.present?
          ActiveRecord::Base.transaction do
            @issues.each do |issue_data|
              jira_user_data = issue_data[:assignee] # Extracted assignee data from the issue
              # Find or create the Jira user
              jira_user = JiraUser.find_by(account_id: jira_user_data[:account_id]) if jira_user_data
  
              issue = nil # Initialize issue variable
  
              with_retry do
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
              end
  
              # Save attachments and comments for the issue
              save_attachments(issue_data[:attachments], issue, access_token) if issue_data[:attachments].present?
              save_comments(issue_data[:comments], issue) if issue_data[:comments].present?
              # save_histories(issue_data[:histories], issue) if issue_data[:histories].present?
            end
          end
  
          Rails.logger.info('Issues fetched successfully.')
          @project = Project.find(id)
          UpdateIssueUserJob.perform_now(@project, @project.user_mappings.all.pluck(:jira_user_id), @project.user_mappings.all.pluck(:code_giant_user_id), token, workspace_id)
            @project.destroy
        else
          Rails.logger.info('No issues found.')
        end
  
      rescue RestClient::Exceptions::ReadTimeout => e
        Rails.logger.error("Timeout error: #{e.message}")
        retries += 1
        if retries < MAX_RETRIES
          sleep(2**retries) # Exponential backoff
          retry
        else
          Rails.logger.error("Failed after #{MAX_RETRIES} attempts due to timeout.")
        end
      rescue RestClient::Forbidden => e
        Rails.logger.error("Forbidden error: #{e.message}")
        # Additional handling for 403 Forbidden errors, such as notifying an admin or user
      rescue StandardError => e
        Rails.logger.error("Unexpected error: #{e.message}")
        raise
      end
    end
  
    private
  
    def with_retry
      retries = 0
      begin
        yield
      rescue ActiveRecord::StatementInvalid => e
        if retries < 3 && e.message =~ /database is locked/
          retries += 1
          sleep(0.5)
          retry
        else
          raise
        end
      end
    end
  
    def save_attachments(attachments_data, issue, token)
      attachments_data.each do |attachment|
        download_and_save_attachment_to_storage(attachment[:url], attachment[:filename], issue, token)
      end
    end
  
    def download_and_save_attachment_to_storage(url, filename, issue, token)
      if url.present?
        response = RestClient::Request.execute(
          method: :get,
          url: url,
          headers: { Authorization: "Bearer #{token}" },
          timeout: 300 # Increase timeout duration
        )
        file_content = response.body
        issue.attachments.attach(io: StringIO.new(file_content), filename: filename)
        Rails.logger.info("Attachment saved to Active Storage for issue ID #{issue.id}: #{filename}")
      end
    end
  
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
            Rails.logger.info("Comment with ID #{comment['id']} updated successfully for issue ID #{issue.id}.")
          else
            issue.comments.create!(
              issue_id: issue.id,
              id: comment['id'],
              author: comment['author']['displayName'],
              body: (comment['body'].is_a?(Hash) ? formatted_body(comment['body']) : comment['body']),
              created_at: comment['created'],
              updated_at: comment['updated']
            )
            Rails.logger.info("Comment with ID #{comment['id']} created successfully for issue ID #{issue.id}.")
          end
        rescue ActiveRecord::RecordNotUnique => e
          Rails.logger.warn("Comment with ID #{comment['id']} already exists for issue ID #{issue.id}.")
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