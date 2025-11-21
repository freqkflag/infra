module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user
    
    def connect
      self.current_user = find_verified_user
    end
    
    private
    
    def find_verified_user
      token = request.params[:token] || request.headers['Authorization']&.split(' ')&.last
      
      if token
        decoded = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
        User.find(decoded['user_id'])
      else
        reject_unauthorized_connection
      end
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      reject_unauthorized_connection
    end
  end
end

