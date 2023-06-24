require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  describe 'POST /auth' do
    let(:user_attributes) { attributes_for(:user) }

    context 'when signing up' do
      it 'creates a new user' do
        post '/auth', params: user_attributes

        expect(response).to have_http_status(:success)
        expect(json['status']).to eq('success')
        expect(json['data']['email']).to eq(user_attributes[:email])

		expect(headers['access-token']).to be_present
		expect(headers['client']).to be_present
		expect(headers['uid']).to be_present
      end
    end

    context 'when signing in' do
      let!(:user) { create(:user, email: user_attributes[:email]) }

      it 'returns authentication credentials' do
        post '/auth/sign_in', params: {
          email: user_attributes[:email],
          password: user_attributes[:password]
        }

        expect(response).to have_http_status(:success)		
        expect(json['data']['email']).to eq(user_attributes[:email])

		expect(headers['access-token']).to be_present
		expect(headers['client']).to be_present
		expect(headers['uid']).to be_present
      end
    end

    context 'when signing out' do
      let!(:user) { create(:user, email: user_attributes[:email]) }
      let(:auth_headers) { user.create_new_auth_token }

      it 'signs out the user' do
        delete '/auth/sign_out', headers: auth_headers

        expect(response).to have_http_status(:success)
        expect(json['success']).to be true
        expect(user.reload.tokens).to be_empty
      end
    end
  end

  describe 'PUT /auth' do
    let!(:user) { create(:user) }
    let(:auth_headers) { user.create_new_auth_token }

    context 'when changing password' do
      it 'changes the user password' do
        new_password = Faker::Internet.password
        put '/auth', params: {
          password: new_password,
          password_confirmation: new_password
        }, headers: auth_headers

        expect(response).to have_http_status(:success)
        expect(json['status']).to eq('success')
        expect(user.reload.valid_password?(new_password)).to be true
      end
    end
  end
end
