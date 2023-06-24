require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:user) { create(:user) }
  let(:user_id) { user.id }
  let(:headers) { user.create_new_auth_token }

  describe 'GET /users' do
    before { get '/users', params: {}, headers: headers }

    it 'returns users' do
      expect(json).not_to be_empty
      expect(json.size).to eq(1)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end    
  end

  describe 'GET /users/:id' do
    before { get "/users/#{user_id}", headers: headers }

    context 'when the record exists' do
      it 'returns the user' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(user_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:user_id) { 'non-existing-id' }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do        
        expect(response.body).to match(/Couldn't find user/)
      end
    end
  end

  describe 'PUT /users/:id' do
    let(:new_attributes) { { name: 'New Name', email: 'funny@email.com' } }

    context 'when the record exists' do
      before { put "/users/#{user_id}", params: new_attributes, headers: headers }

      it 'updates the name' do
        puts response.status
        expect(json['name']).to eq(new_attributes[:name])
      end

      it 'updates the email' do     
        expect(json['email']).to eq(new_attributes[:email])
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exists' do
      let(:user_id) { 'non-existing-id' }

      before { put "/users/#{user_id}", params: new_attributes, headers: headers }

      it 'returns a validation failure message' do
        expect(response.body).to match("Couldn't find user")
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end

    context 'when the user is not logged in' do
      before { put "/users/#{user_id}", params: new_attributes }
  
      it 'returns a 401 status code' do
        expect(response).to have_http_status(401)
      end
    end
  end
  
  describe 'DELETE /users/:id' do
    context 'when the user is deleted' do
      before { delete "/users/#{user_id}", headers: headers }

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end    

    context 'when a non-existing user is deleted' do
      let(:user_id) { 100 }
      before { delete "/users/#{user_id}", headers: headers }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a validation failure message' do
        expect(response.body).to match("Couldn't find user")
      end
    end    
  end
end