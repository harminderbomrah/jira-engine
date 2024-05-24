require 'rest-client'
require 'json'
module Jira
 
  class JiraIssueService
    def initialize(access_token, project_id, jira_site_id)
      @access_token = access_token
      @project_id = project_id
      @issues_endpoint = "https://api.atlassian.com/ex/jira/#{jira_site_id}/rest/api/3/search"
      @comments_endpoint = "https://api.atlassian.com/ex/jira/#{jira_site_id}/rest/api/3/issue/"
      @history_endpoint = "https://api.atlassian.com/ex/jira/#{jira_site_id}/rest/api/3/issue/"
      @assignees_endpoint = "https://api.atlassian.com/ex/jira/#{jira_site_id}/rest/api/3/user/search"
    end
  
    def fetch_issues
      all_issues = []
      start_at = 0
      max_results = 100
  
      loop do
        response = RestClient.get(@issues_endpoint, {
          Authorization: "Bearer #{@access_token}",
          params: {
            jql: "project = '#{@project_id}'",
            startAt: start_at,
            maxResults: max_results,
            expand: 'comment' # Include comments in the response
          }
        })
        puts "status: #{response.code}"
  
        issues_data = JSON.parse(response.body)
        break if issues_data['issues'].empty?
  
        issues_batch = issues_data['issues'].map do |issue|
          assignee_data = issue['fields']['assignee']
          issue_key = issue['key']
  
          # Fetch comments for the current issue
          comments_data = fetch_comments(issue_key)
  
          # Fetch histories for the current issue
          # histories_data = fetch_histories(issue_key)
  
          {
            key: issue_key,
            summary: issue['fields']['summary'],
            description: extract_description_text(issue['fields']['description']),
            status: issue['fields']['status']['name'],
            creator_display_name: issue['fields']['creator']['displayName'],
            reporter_display_name: issue['fields']['reporter']['displayName'],
            created_at: issue['fields']['created'],
            updated_at: issue['fields']['updated'],
            priority: issue['fields']['priority']['name'],
            jira_project_id: @project_id,
            issue_id: issue['id'],
            issue_type: issue['fields']['issuetype']['name'],
            assignee: assignee_data ? { # Check if assignee data exists
              account_id: assignee_data['accountId'],
              display_name: assignee_data['displayName'],
              avatarUrls: assignee_data['avatarUrls'] # Including all avatar URLs
            } : nil,
            duedate: issue['fields']['duedate'] || nil, # Extract duedate
            comments: comments_data, # Include comments data in the issue hash
            # histories: histories_data, # Include histories data in the issue hash
            time_originalestimate: issue['fields']['timeoriginalestimate'] || nil, # Extract timeoriginalestimate
            time_estimate: issue['fields']['timeestimate'] || nil  # Extract timeestimate
          }
        end
  
        all_issues.concat(issues_batch)
        break if issues_batch.length < max_results
        start_at += max_results
      end
  
      if all_issues.any?
        { issues: all_issues, error: nil }
      else
        { issues: [], error: 'No issues found.' }
      end
      rescue RestClient::Unauthorized => e
        { issues: [], error: "Error: Unauthorized - Your access token may have expired or is invalid." }
      rescue RestClient::Forbidden => e
        { issues: [], error: "Error: Forbidden - You do not have permission to access these issues." }
      rescue RestClient::ExceptionWithResponse, RestClient::TooManyRequests, Exception => e
        # error_response = JSON.parse(e.response)
        # { issues: [], error: "Error: #{error_response['message']}" }
        puts e
        sleep 10
        retry
      rescue StandardError => e
        { issues: [], error: "Error: #{e.message}" }
    end
  
    def fetch_assignees
      response = RestClient.get(@assignees_endpoint, {
        Authorization: "Bearer #{@access_token}",
        params: {
          query: '',
          project: ''
        }
      })
      assignees_data = JSON.parse(response.body)
      assignees_data.select { |assignee| assignee['accountType'] == 'atlassian' }.map do |assignee|
        JiraUser.find_or_create_by(display_name: assignee['displayName']) do |user|
          user.account_id = assignee['accountId']
        end
      end
    rescue RestClient::ExceptionWithResponse, RestClient::TooManyRequests, Exception => e
      # Handle exceptions
      puts "Error fetching assignees: #{e.message}"
      []
    end
  
    private
  
    def fetch_comments(issue_key)
      begin
        comments_endpoint = "#{@comments_endpoint}#{issue_key}/comment"
        response = RestClient.get(comments_endpoint, {
          Authorization: "Bearer #{@access_token}"
        })
        JSON.parse(response.body)
      rescue RestClient::ExceptionWithResponse, RestClient::TooManyRequests, Exception => e
        sleep 10
        retry
      end
    end
  
    def fetch_histories(issue_key)
      begin
        history_endpoint = "#{@history_endpoint}#{issue_key}/changelog"
        response = RestClient.get(history_endpoint, {
          Authorization: "Bearer #{@access_token}"
        })
        JSON.parse(response.body)
      rescue RestClient::ExceptionWithResponse, RestClient::TooManyRequests, Exception => e
        sleep 10
        retry
      end
    end
  
    def extract_description_text(description)
      return nil unless description&.dig('content').is_a?(Array)
  
      description['content'].map do |content|
        if content['type'] == 'paragraph'
          extract_paragraph_text(content)
        elsif content['content']
          extract_description_text(content)
        end
      end.compact.join("\n\n")
    end
  
    def extract_paragraph_text(paragraph)
      return unless paragraph&.dig('content').is_a?(Array)
  
      paragraph['content'].map do |item|
        item['text'] if item['type'] == 'text'
      end.compact.join("\n")
    end
  end
end