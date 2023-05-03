# frozen_string_literal: true

module Api
  module V1
    class TeamsController < ApplicationController
      include ActionController::HttpAuthentication::Token
      PAGINATION_LIMIT = 10

      before_action :authenticate_user, only: %i[create update destroy]
      def index
        @teams = Team.limit(limit).offset(params[:offset])

        render json: TeamsSerializer.new(@teams).as_json, status: :ok, status: :ok
      end

      def create
        @team = Team.new(team_params)

        if @team.save
          render json: { name: @team.name }, status: :created
        else
          render json: @team.errors, status: :unprocessable_entity
        end
      end

      def destroy
        Team.find(params[:id]).destroy!

        head :no_content
      end

      def update
        @team = Team.find(params[:id])

        if @team.update(name: params[:name])
          render json: { name: @team.name }, status: :accepted
        else
          render json: @team.errors, status: :unprocessable_entity
        end
      end

      def show
        @team = Team.find(params[:id])

        render json: { name: @team.name }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: {}, status: :no_content
      end

      def show_members
        @team_members = Member.where(team_id: params[:id])

        render json: MembersSerializer.new(@team_members).as_json, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: {}, status: :no_content
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

      def team_params
        params.require(:team).permit(:name)
      end
    end
  end
end
