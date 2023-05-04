# frozen_string_literal: true

require 'rails_helper'

describe 'Authentication', type: :request do
  describe 'POST /authenticate' do
    let(:user) { FactoryBot.create(:user, username: 'member1', password: 'password1') }

    it 'authenticates the client' do
      post '/api/v1/authenticate', params: { username: user.username, password: user.password }
      decoded_token = JWT.decode(
        response_body['token'],
        AuthenticationTokenService::HMAC_SECRET,
        true,
        { algorithm: AuthenticationTokenService::ALGO_TYPE }
      )

      expect(response).to have_http_status(:created)
      expect(decoded_token).to eq(
        [{ 'user_id' => user.id }, { 'alg' => 'HS256' }]
      )
    end

    it 'returns error when username is missing' do
      post '/api/v1/authenticate', params: { password: 'password1' }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body).to eq({
                                    'error' => 'param is missing or the value is empty: username'
                                  })
    end

    it 'returns error when password is missing' do
      post '/api/v1/authenticate', params: { username: 'member1' }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body).to eq({
                                    'error' => 'param is missing or the value is empty: password'
                                  })
    end

    it 'returns error when password is incorrect' do
      post '/api/v1/authenticate', params: { username: user.username, password: 'i_am_hacker' }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
