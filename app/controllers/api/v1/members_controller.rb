# frozen_string_literal: true

module Api
  module V1
    class MembersController < ApplicationController
      PAGINATION_LIMIT = 100
      def index
        @members = Member.limit(limit).offset(params[:offset])

        render json: MembersSerializer.new(@members).as_json, status: :ok
        # render json: @members, status: :ok
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

      private

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
    end
  end
end
