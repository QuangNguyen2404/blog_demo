# spec/controllers/sessions_controller_spec.rb
require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let!(:user) { create(:user, email: 'test@example.com', password: 'password123') }

  describe 'POST #create' do
    context 'with valid credentials' do
      let(:valid_params) do
        {
          email: 'test@example.com',
          password: 'password123'
        }
      end

      it 'returns success status' do
        post :create, params: valid_params
        expect(response).to have_http_status(:ok)
      end

      it 'returns a JWT token' do
        post :create, params: valid_params
        
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('token')
        expect(json_response['token']).to be_present
      end

      it 'returns user information without sensitive data' do
        post :create, params: valid_params
        
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('user')
        expect(json_response['user']).to have_key('email')
        expect(json_response['user']).not_to have_key('password_digest')
        expect(json_response['user']).not_to have_key('created_at')
        expect(json_response['user']).not_to have_key('updated_at')
      end

      it 'generates token with correct payload' do
        post :create, params: valid_params
        
        token = JSON.parse(response.body)['token']
        decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
        
        expect(decoded_token['user_id']).to eq(user.id)
        expect(decoded_token['email']).to eq(user.email)
        expect(decoded_token['exp']).to be > Time.current.to_i
      end

      it 'sets token expiration to 24 hours' do
        post :create, params: valid_params
        
        token = JSON.parse(response.body)['token']
        decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
        
        expected_exp = 24.hours.from_now.to_i
        expect(decoded_token['exp']).to be_within(5).of(expected_exp)
      end
    end

    context 'with invalid credentials' do
      let(:invalid_params) do
        {
          email: 'test@example.com',
          password: 'wrongpassword'
        }
      end

      it 'returns unauthorized status' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns error message' do
        post :create, params: invalid_params
        
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid email or password')
      end

      it 'does not return a token' do
        post :create, params: invalid_params
        
        json_response = JSON.parse(response.body)
        expect(json_response).not_to have_key('token')
      end
    end

    context 'with non-existent user' do
      let(:nonexistent_params) do
        {
          email: 'nonexistent@example.com',
          password: 'password123'
        }
      end

      it 'returns unauthorized status' do
        post :create, params: nonexistent_params
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns error message' do
        post :create, params: nonexistent_params
        
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid email or password')
      end
    end

    context 'with missing parameters' do
      it 'handles missing email' do
        post :create, params: { password: 'password123' }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'handles missing password' do
        post :create, params: { email: 'test@example.com' }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'returns success status' do
      delete :destroy
      expect(response).to have_http_status(:ok)
    end

    it 'returns logout message' do
      delete :destroy
      
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to eq('Logged out successfully')
    end

    context 'when user is authenticated' do
      before do
        token = JWT.encode({ user_id: user.id }, Rails.application.credentials.secret_key_base)
        request.headers['Authorization'] = "Bearer #{token}"
      end

      it 'still returns success' do
        delete :destroy
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET #show' do
    context 'when user is authenticated' do
      before do
        token = JWT.encode({ user_id: user.id }, Rails.application.credentials.secret_key_base)
        request.headers['Authorization'] = "Bearer #{token}"
      end

      it 'returns success status' do
        get :show
        expect(response).to have_http_status(:ok)
      end

      it 'returns authenticated status' do
        get :show
        
        json_response = JSON.parse(response.body)
        expect(json_response['authenticated']).to be true
      end

      it 'returns user information without sensitive data' do
        get :show
        
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('user')
        expect(json_response['user']['email']).to eq(user.email)
        expect(json_response['user']).not_to have_key('password_digest')
        expect(json_response['user']).not_to have_key('created_at')
        expect(json_response['user']).not_to have_key('updated_at')
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized status' do
        get :show
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns unauthenticated status' do
        get :show
        
        json_response = JSON.parse(response.body)
        expect(json_response['authenticated']).to be false
      end

      it 'does not return user information' do
        get :show
        
        json_response = JSON.parse(response.body)
        expect(json_response).not_to have_key('user')
      end
    end

    context 'with invalid token' do
      before do
        request.headers['Authorization'] = "Bearer invalid_token"
      end

      it 'returns unauthorized status' do
        get :show
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with expired token' do
      before do
        expired_token = JWT.encode(
          { user_id: user.id, exp: 1.hour.ago.to_i },
          Rails.application.credentials.secret_key_base
        )
        request.headers['Authorization'] = "Bearer #{expired_token}"
      end

      it 'returns unauthorized status' do
        get :show
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'private methods' do
    describe '#generate_jwt_token' do
      it 'generates a valid JWT token' do
        controller = SessionsController.new
        token = controller.send(:generate_jwt_token, user)
        
        decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
        expect(decoded_token['user_id']).to eq(user.id)
        expect(decoded_token['email']).to eq(user.email)
        expect(decoded_token['exp']).to be > Time.current.to_i
      end

      it 'includes expiration time' do
        controller = SessionsController.new
        token = controller.send(:generate_jwt_token, user)
        
        decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
        expected_exp = 24.hours.from_now.to_i
        expect(decoded_token['exp']).to be_within(5).of(expected_exp)
      end
    end
  end
end
