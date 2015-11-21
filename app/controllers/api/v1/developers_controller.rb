module Api
  module V1
    class DevelopersController < ApplicationController
      def index
         render json: Developer.all, status: 201
      end
    end
  end
end