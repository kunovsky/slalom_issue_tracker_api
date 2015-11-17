module Api
  module V1
    class IssuesController < ApplicationController
      before_filter :get_jira_client
      def index
         render json: @jira_client.Issue.all, status: 201
      end
    end
  end
end
