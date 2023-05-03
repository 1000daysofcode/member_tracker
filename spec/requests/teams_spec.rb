# frozen_string_literal: true

require 'rails_helper'

describe 'Teams API', type: :request do
  Project.destroy_all

  describe 'GET /teams' do
    before do
      FactoryBot.create(:team, name: 'Test Team 1')
      FactoryBot.create(:team, name: 'Test Team 2')
    end

    it 'returns all teams' do
      get '/api/v1/teams'

      expect(response).to have_http_status(:success)
      expect(response_body.size).to eq(2)
      expect(response_body).to eq([{ 'name' => 'Test Team 1' }, { 'name' => 'Test Team 2' }])
    end

    it 'returns a subarray of teams based on limit' do
      get '/api/v1/teams', params: { limit: 1 }

      expect(response).to have_http_status(:success)
      expect(response_body.size).to eq(1)
      expect(response_body).to eq([{ 'name' => 'Test Team 1' }])
    end

    it 'returns a subarray of teams based on limit and offset' do
      get '/api/v1/teams', params: { limit: 1, offset: 1 }

      expect(response).to have_http_status(:success)
      expect(response_body.size).to eq(1)
      expect(response_body).to eq([{ 'name' => 'Test Team 2' }])
    end

    it 'limits response size to 10 teams' do
      expect(Team).to receive(:limit).with(10).and_call_original

      get '/api/v1/teams', params: { limit: 50 }
    end
  end

  describe 'POST /teams' do
    let!(:user) { FactoryBot.create(:user, password: 'password1') }

    before do
      allow(AuthenticationTokenService).to receive(:decode).and_return(user.id)
    end

    it 'creates a new team' do
      expect do
        post '/api/v1/teams',
             params: { team: { name: 'Test Team 1' } },
             headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiMSJ9.Jddfq3-7sAXByGP8q58Iu43FIMA1DW1Kz_08tGb9VKI' }
      end.to change { Team.count }.from(0).to(1)
      expect(Team.count).to eq(1)

      expect(response).to have_http_status(:created)
      expect(response_body).to eq({ 'name' => 'Test Team 1' })
    end
  end

  describe 'DELETE /teams/:id' do
    let!(:user) { FactoryBot.create(:user, password: 'password1') }
    let!(:team) { FactoryBot.create(:team, name: 'Test Team 1') }

    before do
      allow(AuthenticationTokenService).to receive(:decode).and_return(user.id)
    end

    it 'deletes a team' do
      expect do
        delete "/api/v1/teams/#{team.id}",
               headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiMSJ9.Jddfq3-7sAXByGP8q58Iu43FIMA1DW1Kz_08tGb9VKI' }
      end.to change { Team.count }.from(1).to(0)

      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'PUT /teams/:id' do
    let!(:user) { FactoryBot.create(:user, password: 'password1') }
    let!(:team) { FactoryBot.create(:team, name: 'Test Team 1') }

    before do
      allow(AuthenticationTokenService).to receive(:decode).and_return(user.id)
    end

    it 'updates a team' do
      patch "/api/v1/teams/#{team.id}",
            params: { name: 'Test Team 2' },
            headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiMSJ9.Jddfq3-7sAXByGP8q58Iu43FIMA1DW1Kz_08tGb9VKI' }

      expect(response).to have_http_status(:accepted)
      expect(response_body['name']).to eq('Test Team 2')
    end
  end

  describe 'GET /team/:id' do
    let!(:team1) { FactoryBot.create(:team, name: 'Test Team') }
    let!(:team2) { FactoryBot.create(:team, name: 'Test Team 2') }

    before do
      FactoryBot.create(:member, first_name: 'Bill', last_name: 'Bob', city: 'Yale',
                        state: 'Connecticut', country: 'USA', team_id: team1.id)
      FactoryBot.create(:member, first_name: 'Jenny', last_name: 'Gump', city: 'New Orleans',
                        state: 'Louisiana', country: 'USA', team_id: team1.id)
      FactoryBot.create(:member, first_name: 'Foo', last_name: 'Bar', city: 'Palo Alto',
                        state: 'California', country: 'USA', team_id: team2.id)
    end

    it 'displays a specific team' do
      get "/api/v1/teams/#{team1.id}",
          headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiMSJ9.Jddfq3-7sAXByGP8q58Iu43FIMA1DW1Kz_08tGb9VKI' }

      expect(response).to have_http_status(:ok)
      expect(response_body).to eq({ 'name' => 'Test Team' })
    end

    it 'displays all members of a team' do
      get "/api/v1/teams/#{team1.id}/members",
          headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiMSJ9.Jddfq3-7sAXByGP8q58Iu43FIMA1DW1Kz_08tGb9VKI' }

      expect(response).to have_http_status(:ok)
      expect(response_body.length).to eq(2)
      expect(response_body).to eq([first_response, second_response])
    end
  end
end

def first_response
  {
    'name' => 'Bill Bob',
    'city' => 'Yale',
    'state' => 'Connecticut',
    'country' => 'USA',
    'team' => 'Test Team',
    'projects' => []
  }
end

def second_response
  {
    'name' => 'Jenny Gump',
    'city' => 'New Orleans',
    'state' => 'Louisiana',
    'country' => 'USA',
    'team' => 'Test Team',
    'projects' => []
  }
end
