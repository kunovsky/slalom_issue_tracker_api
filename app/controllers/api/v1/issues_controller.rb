module Api
  module V1
    class IssuesController < ApplicationController
      before_filter :get_jira_client
      def index
        list = DefectList.last
        if params[:force] != 'true' && list.present? && list.created_at >= Time.now - 1.days
           render json: list.data, status: 201
        else
          # render json: @jira_client.Issue.all, status: 201
          render json: DefectList.create_defect_information(@jira_client.Project.all), status: 201
        end
      end
    end
  end
end