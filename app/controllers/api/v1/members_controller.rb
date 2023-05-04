# frozen_string_literal: true

module Api
  module V1
    class MembersController < ApplicationController
      include ActionController::HttpAuthentication::Token
      PAGINATION_LIMIT = 50

      before_action :authenticate_user, only: %i[create update destroy]
      def index
        @members = Member.limit(limit).offset(params[:offset])

        render json: MembersSerializer.new(@members).as_json, status: :ok
      end

      def create
        @member = Member.new(member_params)

        if @member.save
          render json: MemberSerializer.new(@member).as_json, status: :created
        else
          render json: @member.errors, status: :unprocessable_entity
        end
      end

      def destroy
        Member.find(params[:id]).destroy!

        head :no_content
      end

      def update
        @member = Member.find(params[:id])

        begin
          params[:team_id] = team_id
        rescue ActiveRecord::RecordNotFound, NoMethodError
          render json: @member.errors, status: :unprocessable_entity and return
        end

        if @member.update(allowable_params)
          render json: MemberSerializer.new(@member).as_json, status: :accepted
        else
          render json: @member.errors, status: :unprocessable_entity
        end
      end

      def show
        @member = Member.find(params[:id])

        render json: MemberSerializer.new(@member).as_json, status: :ok
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

      def team_id
        return @member.team_id unless params.include?(:team_name)

        Team.find_by(name: params[:team_name]).id
      end

      def limit
        [PAGINATION_LIMIT, params.fetch(:limit, PAGINATION_LIMIT).to_i].min
      end

      def member_params
        params.require(:member).permit(
          :first_name,
          :last_name,
          :city,
          :state,
          :country,
          :team_id
        )
      end

      def allowable_params
        params.permit(
          :first_name,
          :last_name,
          :city,
          :state,
          :country,
          :team_id
        )
      end
    end
  end
end
