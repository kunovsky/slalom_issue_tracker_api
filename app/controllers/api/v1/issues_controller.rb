module Api
  module V1
    class IssuesController < ApplicationController
      before_filter :get_jira_client
      def index
         render json: DefectList.create_defect_information(@jira_client.Project.all), status: 201
      end
    end
  end
end