# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MembersController, type: :controller do
  Member.destroy_all

  let!(:team) { FactoryBot.create(:team, name: 'Test Team') }
  let!(:user) { FactoryBot.create(:user, password: 'password1') }

  it 'limits response size to 50 members' do
    expect(Member).to receive(:limit).with(50).and_call_original

    get :index, params: { limit: 100 }
  end

  describe 'POST create' do
    context 'with authorization header' do
      before do
        allow(AuthenticationTokenService).to receive(:decode).and_return(user.id)
      end

      it 'creates a new member' do
        expect do
          post :create,
               params: { member: { first_name: 'Bill', last_name: 'Bob', city: 'Yale',
                                   state: 'Connecticut', country: 'USA', team_id: team.id },
                         headers: test_bearer }
        end.to change { Member.count }.from(0).to(1)

        expect(Team.count).to eq(1)
      end
    end

    context 'missing authorization header' do
      it 'returns status 401' do
        post :create,
             params: { member: { first_name: 'Bill', last_name: 'Bob', city: 'Yale',
                                 state: 'Connecticut', country: 'USA', team_id: team.id },
                       headers: {} }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE destroy' do
    context 'missing authorization header' do
      it 'returns status 401' do
        delete :destroy, params: { id: 1 }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT /members/:id' do
    let!(:user) { FactoryBot.create(:user, password: 'password1') }
    let!(:team) { FactoryBot.create(:team, name: 'Test Team') }
    let!(:alt_team) { FactoryBot.create(:team, name: 'Alternative Team') }
    let!(:member) do
      FactoryBot.create(:member, first_name: 'Bill', last_name: 'Bob', city: 'Yale',
                                 state: 'Connecticut', country: 'USA', team_id: team.id)
    end

    context 'with authorization header' do
      before do
        allow(AuthenticationTokenService).to receive(:decode).and_return(user.id)
      end

      it 'updates a member' do
        patch :update, params: {
          id: member.id, country: 'Canada',
          headers: test_bearer
        }

        expect(response).to have_http_status(:accepted)
      end

      it 'changes a member team' do
        patch :update, params: {
          id: member.id, team_name: 'Alternative Team',
          headers: test_bearer
        }

        expect(response).to have_http_status(:accepted)
      end
    end

    context 'missing authorization header' do
      it 'returns status 401' do
        patch :update, params: { id: member.id, country: 'Canada', headers: {} }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /members/:id' do
    let!(:team) { FactoryBot.create(:team, name: 'Test Team') }
    let!(:member) do
      FactoryBot.create(:member, first_name: 'Bill', last_name: 'Bob', city: 'Yale',
                                 state: 'Connecticut', country: 'USA', team_id: team.id)
    end

    it 'displays a specific member' do
      get :show, params: {
        id: member.id,
        headers: test_bearer
      }

      expect(response).to have_http_status(:ok)
    end
  end
end
