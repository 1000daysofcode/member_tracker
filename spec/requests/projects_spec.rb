# frozen_string_literal: true

require 'rails_helper'

describe 'Projects API', type: :request do
  Project.destroy_all

  describe 'GET /projects' do
    before do
      FactoryBot.create(:project, name: 'Test Project 1')
      FactoryBot.create(:project, name: 'Test Project 2')
    end

    it 'returns all projects' do
      get '/api/v1/projects'

      expect(response).to have_http_status(:success)
      expect(response_body.size).to eq(2)
      expect(response_body).to eq([{ 'name' => 'Test Project 1' }, { 'name' => 'Test Project 2' }])
    end

    it 'returns a subarray of projects based on limit' do
      get '/api/v1/projects', params: { limit: 1 }

      expect(response).to have_http_status(:success)
      expect(response_body.size).to eq(1)
      expect(response_body).to eq([{ 'name' => 'Test Project 1' }])
    end

    it 'returns a subarray of projects based on limit and offset' do
      get '/api/v1/projects', params: { limit: 1, offset: 1 }

      expect(response).to have_http_status(:success)
      expect(response_body.size).to eq(1)
      expect(response_body).to eq([{ 'name' => 'Test Project 2' }])
    end

    it 'limits response size to 10 projects' do
      expect(Project).to receive(:limit).with(10).and_call_original

      get '/api/v1/projects', params: { limit: 50 }
    end
  end

  describe 'POST /projects' do
    let!(:user) { FactoryBot.create(:user, password: 'password1') }

    before do
      allow(AuthenticationTokenService).to receive(:decode).and_return(user.id)
    end

    it 'creates a new project' do
      expect do
        post '/api/v1/projects',
             params: { project: { name: 'Test Project 1' } },
             headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiMSJ9.Jddfq3-7sAXByGP8q58Iu43FIMA1DW1Kz_08tGb9VKI' }
      end.to change { Project.count }.from(0).to(1)
      expect(Project.count).to eq(1)

      expect(response).to have_http_status(:created)
      expect(response_body).to eq({ 'name' => 'Test Project 1' })
    end
  end

  describe 'DELETE /projects/:id' do
    let!(:user) { FactoryBot.create(:user, password: 'password1') }
    let!(:project) { FactoryBot.create(:project, name: 'Test Project 1') }

    before do
      allow(AuthenticationTokenService).to receive(:decode).and_return(user.id)
    end

    it 'deletes a project' do
      expect do
        delete "/api/v1/projects/#{project.id}",
               headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiMSJ9.Jddfq3-7sAXByGP8q58Iu43FIMA1DW1Kz_08tGb9VKI' }
      end.to change { Project.count }.from(1).to(0)

      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'PUT /projects/:id' do
    let!(:team) { FactoryBot.create(:team, name: 'Test Team') }
    let!(:user) { FactoryBot.create(:user, password: 'password1') }
    let!(:project) { FactoryBot.create(:project, name: 'Test Project 1') }
    let!(:member) do
      FactoryBot.create(:member, first_name: 'Bill', last_name: 'Bob', city: 'Yale',
                                 state: 'Connecticut', country: 'USA', team_id: team.id)
    end

    before do
      allow(AuthenticationTokenService).to receive(:decode).and_return(user.id)
    end

    it 'updates a project' do
      patch "/api/v1/projects/#{project.id}",
            params: { name: 'Test Project 2' },
            headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiMSJ9.Jddfq3-7sAXByGP8q58Iu43FIMA1DW1Kz_08tGb9VKI' }

      expect(response).to have_http_status(:accepted)
      expect(response_body['name']).to eq('Test Project 2')
    end

    it 'adds a member to a project' do
      patch "/api/v1/projects/#{project.id}/add_member",
            params: { member_id: member.id },
            headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiMSJ9.Jddfq3-7sAXByGP8q58Iu43FIMA1DW1Kz_08tGb9VKI' }

      expect(response).to have_http_status(:accepted)
      expect(response.body).to include('Test Project 1')
    end

    it 'removes a member from a project' do
      patch "/api/v1/projects/#{project.id}/remove_member",
            params: { member_id: member.id },
            headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiMSJ9.Jddfq3-7sAXByGP8q58Iu43FIMA1DW1Kz_08tGb9VKI' }

      expect(response.body).to include('Test Project 1')

      patch :remove_member, params: {
        id: project.id, member_id: member.id,
        headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiMSJ9.Jddfq3-7sAXByGP8q58Iu43FIMA1DW1Kz_08tGb9VKI' }
      }

      expect(response).to have_http_status(:no_content)
      expect(response.body).not_to include('Test Project 1')
    end
  end

  describe 'GET /projects/:id' do
    let(:team) { FactoryBot.create(:team, name: 'Test Team') }
    let(:project1) { FactoryBot.create(:project, name: 'First Test Project') }
    let(:project2) { FactoryBot.create(:project, name: 'Second Test Project') }

    let(:member1) do
      FactoryBot.create(:member, first_name: 'Bill', last_name: 'Bob', city: 'Yale',
                                 state: 'Connecticut', country: 'USA', team_id: team.id)
    end
    let(:member2) do
      FactoryBot.create(:member, first_name: 'Jenny', last_name: 'Gump', city: 'New Orleans',
                                 state: 'Louisiana', country: 'USA', team_id: team.id)
    end
    let(:member3) do
      FactoryBot.create(:member, first_name: 'Foo', last_name: 'Bar', city: 'Palo Alto',
                                 state: 'California', country: 'USA', team_id: team.id)
    end

    before do
      project1.members << member1
      project1.members << member2
      project2.members << member3
    end

    it 'displays a specific project' do
      get "/api/v1/projects/#{project1.id}",
          headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiMSJ9.Jddfq3-7sAXByGP8q58Iu43FIMA1DW1Kz_08tGb9VKI' }

      expect(response).to have_http_status(:ok)
      expect(response_body).to eq({ 'name' => 'First Test Project' })
    end

    it 'shows members of a project' do
      get "/api/v1/projects/#{project1.id}/members",
          headers: { 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiMSJ9.Jddfq3-7sAXByGP8q58Iu43FIMA1DW1Kz_08tGb9VKI' }

      expect(response).to have_http_status(:ok)
      expect(response_body.length).to eq(2)
      expect(response_body.first['projects']).to eq(["First Test Project"])
      expect(response_body.last['projects']).to eq(["First Test Project"])
    end
  end
end

