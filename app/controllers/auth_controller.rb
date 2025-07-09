class AuthController < ApplicationController
  skip_before_action :authenticate_user!

  def register
    user = User.new(user_params)
    if user.save
      render json: { token: jwt_token(user) }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      render json: { token: jwt_token(user) }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  private

  def user_params
    params.require(:auth).permit(:email, :password)
  end

  def jwt_token(user)
    payload = { user_id: user.id }
    JWT.encode(payload, Rails.application.credentials.secret_key_base)  
  end
end
