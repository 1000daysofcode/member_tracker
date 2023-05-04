# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::TeamsController, type: :controller do
  Team.destroy_all

  let!(:user) { FactoryBot.create(:user, password: 'password1') }

  it 'limits response size to 50 teams' do
    expect(Team).to receive(:limit).with(10).and_call_original

    get :index, params: { limit: 50 }
  end

  describe 'POST create' do
    context 'with authorization header' do
      before do
        allow(AuthenticationTokenService).to receive(:decode).and_return(user.id)
      end

      it 'creates a new team' do
        expect do
          post :create,
               params: { team: { name: 'Test Team 1' },
                         headers: test_bearer }
        end.to change { Team.count }.from(0).to(1)

        expect(Team.count).to eq(1)
      end
    end

    context 'missing authorization header' do
      it 'returns status 401' do
        post :create,
             params: { team: { name: 'Test Team 1' },
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

  describe 'PUT update team' do
    let!(:user) { FactoryBot.create(:user, password: 'password1') }
    let!(:team) { FactoryBot.create(:team, name: 'Test Team 1') }

    context 'with authorization header' do
      before do
        allow(AuthenticationTokenService).to receive(:decode).and_return(user.id)
      end

      it 'updates a team' do
        patch :update, params: {
          id: team.id, name: 'Test Team 2',
          headers: test_bearer
        }

        expect(response).to have_http_status(:accepted)
      end
    end

    context 'missing authorization header' do
      it 'returns status 401' do
        patch :update, params: { id: team.id, name: 'Test Team 2', headers: {} }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET show team' do
    let!(:team) { FactoryBot.create(:team, name: 'Test Team 1') }
    let!(:team2) { FactoryBot.create(:team, name: 'Test Team 2') }

    before do
      FactoryBot.create(:member, first_name: 'Bill', last_name: 'Bob', city: 'Yale',
                                 state: 'Connecticut', country: 'USA', team_id: team.id)
      FactoryBot.create(:member, first_name: 'Jenny', last_name: 'Gump', city: 'New Orleans',
                                 state: 'Louisiana', country: 'USA', team_id: team.id)
      FactoryBot.create(:member, first_name: 'Foo', last_name: 'Bar', city: 'Palo Alto',
                                 state: 'California', country: 'USA', team_id: team2.id)
    end

    it 'displays a specific team' do
      get :show, params: {
        id: team.id,
        headers: test_bearer
      }

      expect(response).to have_http_status(:ok)
    end

    it 'displays all members of a team' do
      get :show_members, params: {
        id: team.id,
        headers: test_bearer
      }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).length).to eq(2)
    end
  end
end
