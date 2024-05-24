Rails.application.config.middleware.use OmniAuth::Builder do
  OmniAuth.config.allowed_request_methods = [:post, :get]

  provider :atlassian_oauth2,
           ENV['JIRA_CLIENT_ID'],
           ENV['JIRA_CLIENT_SECRET'],
           scope: "offline_access read:jira-user read:jira-work",
           prompt: "consent"

  # Specify what should happen if OmniAuth encounters a failure
  OmniAuth.config.on_failure = Proc.new do |env|
    # Use the SessionsController's failure action
    # Make sure you have defined the 'sessions#failure' action in your controller
    SessionsController.action(:failure).call(env)
  end
end
