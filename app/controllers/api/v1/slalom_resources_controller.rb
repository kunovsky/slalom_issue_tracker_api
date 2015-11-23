module Api
  module V1
    class SlalomResourcesController < ApplicationController
      def create
        SlalomResource.create_slalom_resources_from_request(JSON.parse(params[:resources]))
        render json: {}, status: 201
      end
    end
  end
end