# frozen_string_literal: true

require 'rails_helper'

describe 'Members API', type: :request do
  Member.destroy_all

  describe 'GET /members' do
    let!(:team) { FactoryBot.create(:team, name: 'Test Team') }

    before do
      FactoryBot.create(:member, first_name: 'Bill', last_name: 'Bob', city: 'Yale',
                                 state: 'Connecticut', country: 'USA', team_id: team.id)
      FactoryBot.create(:member, first_name: 'Jenny', last_name: 'Gump', city: 'New Orleans',
                                 state: 'Louisiana', country: 'USA', team_id: team.id)
    end

    it 'returns all members' do
      get '/api/v1/members'

      expect(response).to have_http_status(:success)
      expect(response_body.size).to eq(2)
      expect(response_body).to eq([first_response, second_response])
    end

    it 'returns a subarray of members based on limit' do
      get '/api/v1/members', params: { limit: 1 }

      expect(response).to have_http_status(:success)
      expect(response_body.size).to eq(1)
      expect(response_body).to eq([first_response])
    end

    it 'returns a subarray of members based on limit and offset' do
      get '/api/v1/members', params: { limit: 1, offset: 1 }

      expect(response).to have_http_status(:success)
      expect(response_body.size).to eq(1)
      expect(response_body).to eq([second_response])
    end

    it 'limits response size to 50 members' do
      expect(Member).to receive(:limit).with(50).and_call_original

      get '/api/v1/members', params: { limit: 100 }
    end
  end

  describe 'POST /members' do
    let!(:team) { FactoryBot.create(:team, name: 'Test Team') }
    let!(:user) { FactoryBot.create(:user, password: 'password1') }

    before do
      allow(AuthenticationTokenService).to receive(:decode).and_return(user.id)
    end

    it 'creates a new member' do
      expect do
        post '/api/v1/members',
             params: { member: { first_name: 'Bill', last_name: 'Bob', city: 'Yale',
                                 state: 'Connecticut', country: 'USA', team_id: team.id } },
             headers: test_bearer
      end.to change { Member.count }.from(0).to(1)
      expect(Team.count).to eq(1)

      expect(response).to have_http_status(:created)
      expect(response_body).to eq(first_response)
    end
  end

  describe 'DELETE /members/:id' do
    let!(:user) { FactoryBot.create(:user, password: 'password1') }
    let!(:team) { FactoryBot.create(:team, name: 'Test Team') }
    let!(:member) do
      FactoryBot.create(:member, first_name: 'Bill', last_name: 'Bob', city: 'Yale',
                                 state: 'Connecticut', country: 'USA', team_id: team.id)
    end

    before do
      allow(AuthenticationTokenService).to receive(:decode).and_return(user.id)
    end

    it 'deletes a member' do
      expect do
        delete "/api/v1/members/#{member.id}",
               headers: test_bearer
      end.to change { Member.count }.from(1).to(0)

      expect(response).to have_http_status(:no_content)
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

    before do
      allow(AuthenticationTokenService).to receive(:decode).and_return(user.id)
    end

    it 'updates a member' do
      patch "/api/v1/members/#{member.id}",
            params: { country: 'Canada' },
            headers: test_bearer

      expect(response).to have_http_status(:accepted)
      expect(response_body['country']).to eq('Canada')
    end

    it 'changes a member team' do
      patch "/api/v1/members/#{member.id}",
            params: { id: member.id, team_name: 'Alternative Team' },
            headers: test_bearer

      expect(response).to have_http_status(:accepted)
      expect(response_body['team']).to eq(alt_team.name)
    end

    it 'fails when team is changed to an invalid team' do
      patch "/api/v1/members/#{member.id}",
            params: { id: member.id, team_name: 'Wrong Team' },
            headers: test_bearer

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'GET /members/:id' do
    let!(:team) { FactoryBot.create(:team, name: 'Test Team') }
    let!(:member) do
      FactoryBot.create(:member, first_name: 'Bill', last_name: 'Bob', city: 'Yale',
                                 state: 'Connecticut', country: 'USA', team_id: team.id)
    end

    it 'displays a specific member' do
      get "/api/v1/members/#{member.id}",
          headers: test_bearer

      expect(response).to have_http_status(:ok)
      expect(response_body).to eq(first_response)
    end
  end
end
