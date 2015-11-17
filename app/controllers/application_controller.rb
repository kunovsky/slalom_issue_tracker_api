class ApplicationController < ActionController::API
   private
   def get_jira_client
    options = {
           :username => ENV['USERNAME'],
           :password => ENV['PASSWORD'],
           :site     => ENV['SITE'],
           :context_path => '',
           :auth_type => :basic
       }
    @jira_client = JIRA::Client.new(options)
   end
end
