class ApplicationController < ActionController::API
   private
   def get_jira_client
    options = {
           :username => EVN['USER_NAME'],
           :password => EVN['PASSWORD'],
           :site     => EVN['SITE'],
           :context_path => '',
           :auth_type => :basic
       }
    @jira_client = JIRA::Client.new(options)
   end
end
