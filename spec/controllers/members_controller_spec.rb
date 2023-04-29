# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MembersController, type: :controller do
  it 'limits response size to 50 members' do
    expect(Member).to receive(:limit).with(100).and_call_original

    get :index, params: { limit: 200 }
  end
end
