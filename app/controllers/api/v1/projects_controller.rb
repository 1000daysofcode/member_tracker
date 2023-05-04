# frozen_string_literal: true

module Api
  module V1
    class ProjectsController < ApplicationController
      include ActionController::HttpAuthentication::Token
      PAGINATION_LIMIT = 10

      before_action :authenticate_user, only: %i[create add_member remove_member update destroy]
      def index
        @projects = Project.limit(limit).offset(params[:offset])

        render json: ProjectsSerializer.new(@projects).as_json, status: :ok
      end

      def create
        @project = Project.new(project_params)

        if @project.save
          render json: { name: @project.name }, status: :created
        else
          render json: @project.errors, status: :unprocessable_entity
        end
      end

      def destroy
        Project.find(params[:id]).destroy!

        head :no_content
      end

      def update
        @project = Project.find(params[:id])

        if @project.update(name: params[:name])
          render json: { name: @project.name }, status: :accepted
        else
          render json: @project.errors, status: :unprocessable_entity
        end
      end

      def show
        @project = Project.find(params[:id])

        render json: { name: @project.name }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: {}, status: :no_content
      end

      def show_members
        @project = Project.find(params[:id])

        render json: MembersSerializer.new(@project.members).as_json, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: {}, status: :no_content
      end

      def add_member
        @project = Project.find_by(id: params[:id])
        member = Member.find_by(id: params[:member_id])

        unless member
          render json: {}, status: :no_content
          return
        end

        @project.members << member
        if @project.save
          render json: member.projects, status: :accepted
        else
          render json: @project.errors, status: :unprocessable_entity
        end
      end

      def remove_member
        @project = Project.find_by(id: params[:id])
        member = Member.find_by(id: params[:member_id])

        unless @project && member
          render json: {}, status: :no_content
          return
        end

        @project.members.delete member
        head :no_content
      end

      private

      def authenticate_user
        token, _options = token_and_options(request)
        user_id = AuthenticationTokenService.decode(token)
        User.find(user_id)
      rescue ActiveRecord::RecordNotFound, JWT::DecodeError
        head :unauthorized
      end

      def limit
        [PAGINATION_LIMIT, params.fetch(:limit, PAGINATION_LIMIT).to_i].min
      end

      def project_params
        params.require(:project).permit(:name)
      end
    end
  end
end
