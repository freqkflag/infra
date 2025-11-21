class Api::V1::AuthController < ApplicationController
  skip_before_action :authenticate_request, only: [:register, :login]
  
  def register
    user = User.new(user_params)
    user.birth_date = Date.parse(params[:birth_date]) if params[:birth_date]
    
    if user.save
      token = user.generate_jwt
      render json: {
        user: UserSerializer.new(user).as_json,
        token: token
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def login
    user = User.find_by(email: params[:email])
    
    if user && user.authenticate(params[:password])
      token = user.generate_jwt
      render json: {
        user: UserSerializer.new(user).as_json,
        token: token
      }, status: :ok
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end
  
  def refresh
    token = current_user.generate_jwt
    render json: { token: token }, status: :ok
  end
  
  def logout
    render json: { message: 'Logged out successfully' }, status: :ok
  end
  
  private
  
  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :birth_date)
  end
end

