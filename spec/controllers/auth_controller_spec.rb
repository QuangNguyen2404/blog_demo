# spec/controllers/auth_controller_spec.rb
require 'rails_helper'

RSpec.describe AuthController, type: :controller do
  describe 'POST #register' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          auth: {
            email: 'test@example.com',
            password: 'password123'
          }
        }
      end

      it 'creates a new user' do
        expect {
          post :register, params: valid_params
        }.to change(User, :count).by(1)
      end

      it 'returns a JWT token' do
        post :register, params: valid_params
        
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to have_key('token')
      end

      it 'returns a valid JWT token' do
        post :register, params: valid_params
        
        token = JSON.parse(response.body)['token']
        decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
        
        expect(decoded_token['user_id']).to eq(User.last.id)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          auth: {
            email: 'invalid-email',
            password: ''
          }
        }
      end

      it 'does not create a user' do
        expect {
          post :register, params: invalid_params
        }.not_to change(User, :count)
      end

      it 'returns validation errors' do
        post :register, params: invalid_params
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key('errors')
      end
    end

    context 'with duplicate email' do
      let!(:existing_user) { create(:user, email: 'test@example.com') }
      let(:duplicate_email_params) do
        {
          auth: {
            email: 'test@example.com',
            password: 'password123'
          }
        }
      end

      it 'returns validation error' do
        post :register, params: duplicate_email_params
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include(match(/email/i))
      end
    end
  end

  describe 'POST #login' do
    let!(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    context 'with valid credentials' do
      let(:valid_params) do
        {
          email: 'test@example.com',
          password: 'password123'
        }
      end

      it 'returns a JWT token' do
        post :login, params: valid_params
        
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to have_key('token')
      end

      it 'returns a valid JWT token with correct user_id' do
        post :login, params: valid_params
        
        token = JSON.parse(response.body)['token']
        decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
        
        expect(decoded_token['user_id']).to eq(user.id)
      end
    end

    context 'with invalid email' do
      let(:invalid_email_params) do
        {
          email: 'nonexistent@example.com',
          password: 'password123'
        }
      end

      it 'returns unauthorized error' do
        post :login, params: invalid_email_params
        
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Invalid email or password')
      end
    end

    context 'with invalid password' do
      let(:invalid_password_params) do
        {
          email: 'test@example.com',
          password: 'wrongpassword'
        }
      end

      it 'returns unauthorized error' do
        post :login, params: invalid_password_params
        
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Invalid email or password')
      end
    end

    context 'with missing parameters' do
      it 'returns unauthorized error when email is missing' do
        post :login, params: { password: 'password123' }
        
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Invalid email or password')
      end

      it 'returns unauthorized error when password is missing' do
        post :login, params: { email: 'test@example.com' }
        
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Invalid email or password')
      end
    end
  end

  describe 'private methods' do
    let(:user) { create(:user) }

    describe '#jwt_token' do
      it 'generates a valid JWT token' do
        controller = AuthController.new
        token = controller.send(:jwt_token, user)
        
        decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
        expect(decoded_token['user_id']).to eq(user.id)
      end
    end

    describe '#user_params' do
      it 'permits email and password' do
        controller = AuthController.new
        params = ActionController::Parameters.new(
          auth: { email: 'test@example.com', password: 'password', extra_param: 'should_be_filtered' }
        )
        controller.params = params
        
        permitted_params = controller.send(:user_params)
        expect(permitted_params.permitted?).to be true
        expect(permitted_params.keys).to include('email', 'password')
        expect(permitted_params.keys).not_to include('extra_param')
      end
    end
  end
end
