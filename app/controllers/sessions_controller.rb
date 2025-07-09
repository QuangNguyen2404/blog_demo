class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:create, :destroy, :show]

  def create
    user = User.find_by(email: params[:email])
    
    if user&.authenticate(params[:password])
      token = generate_jwt_token(user)
      render json: { 
        token: token, 
        user: user.as_json(except: [:password_digest, :created_at, :updated_at])
      }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def destroy
    render json: { message: 'Logged out successfully' }, status: :ok
  end

  def show
    # Manually check authentication without triggering error response
    header = request.headers['Authorization']
    token = header.split(' ').last if header

    begin
      decoded = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
      user = User.find(decoded['user_id'])
      render json: { 
        user: user.as_json(except: [:password_digest, :created_at, :updated_at]),
        authenticated: true
      }, status: :ok
    rescue
      render json: { authenticated: false }, status: :unauthorized
    end
  end

  private

  def generate_jwt_token(user)
    payload = {
      user_id: user.id,
      email: user.email,
      exp: 24.hours.from_now.to_i 
    }
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end
end
