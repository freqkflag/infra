class ApplicationController < ActionController::API
  before_action :authenticate_request
  
  private
  
  def authenticate_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    
    if token
      decoded = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
      @current_user = User.find(decoded['user_id'])
    else
      render json: { error: 'Not authenticated' }, status: :unauthorized
    end
  rescue JWT::DecodeError, ActiveRecord::RecordNotFound
    render json: { error: 'Invalid token' }, status: :unauthorized
  end
  
  def current_user
    @current_user
  end
end

