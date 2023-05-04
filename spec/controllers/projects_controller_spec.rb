# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ProjectsController, type: :controller do
  Project.destroy_all

  let!(:user) { FactoryBot.create(:user, password: 'password1') }

  it 'limits response size to 50 projects' do
    expect(Project).to receive(:limit).with(10).and_call_original

    get :index, params: { limit: 50 }
  end

  describe 'POST create' do
    context 'with authorization header' do
      before do
        allow(AuthenticationTokenService).to receive(:decode).and_return(user.id)
      end

      it 'creates a new project' do
        expect do
          post :create,
               params: { project: { name: 'Test Project 1' },
                         headers: test_bearer }
        end.to change { Project.count }.from(0).to(1)

        expect(Project.count).to eq(1)
      end
    end

    context 'missing authorization header' do
      it 'returns status 401' do
        post :create,
             params: { project: { name: 'Test Project 1' },
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

  describe 'PUT update project' do
    let!(:team) { FactoryBot.create(:team, name: 'Test Team') }
    let!(:user) { FactoryBot.create(:user, password: 'password1') }
    let!(:project) { FactoryBot.create(:project, name: 'Test Project 1') }
    let!(:member) do
      FactoryBot.create(:member, first_name: 'Bill', last_name: 'Bob', city: 'Yale',
                                 state: 'Connecticut', country: 'USA', team_id: team.id)
    end

    context 'with authorization header' do
      before do
        allow(AuthenticationTokenService).to receive(:decode).and_return(user.id)
      end

      it 'updates a project' do
        patch :update, params: {
          id: project.id, name: 'Test Project 2',
          headers: test_bearer
        }

        expect(response).to have_http_status(:accepted)
      end

      it 'adds a member to a project' do
        patch :add_member, params: {
          id: project.id, member_id: member.id,
          headers: test_bearer
        }

        expect(response).to have_http_status(:accepted)
        expect(response.body).to include('Test Project 1')
      end

      it 'removes a member from a project' do
        patch :add_member, params: {
          id: project.id, member_id: member.id,
          headers: test_bearer
        }

        expect(response.body).to include('Test Project 1')

        patch :remove_member, params: {
          id: project.id, member_id: member.id,
          headers: test_bearer
        }

        expect(response).to have_http_status(:no_content)
        expect(response.body).not_to include('Test Project 1')
      end
    end

    context 'missing authorization header' do
      it 'returns status 401' do
        patch :update, params: { id: project.id, name: 'Test Project 2', headers: {} }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET show project' do
    let(:team) { FactoryBot.create(:team, name: 'Test Team') }
    let(:project1) { FactoryBot.create(:project, name: 'Test Project 1') }
    let(:project2) { FactoryBot.create(:project, name: 'Test Project 2') }

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
      get :show, params: {
        id: project1.id,
        headers: test_bearer
      }

      expect(response).to have_http_status(:ok)
    end

    it 'shows members of a project' do
      get :show_members, params: {
        id: project1.id,
        headers: test_bearer
      }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).length).to eq(2)
    end
  end
end
