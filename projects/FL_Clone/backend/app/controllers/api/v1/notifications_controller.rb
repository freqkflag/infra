class Api::V1::NotificationsController < ApplicationController
  def index
    notifications = current_user.notifications
      .includes(:notifiable)
      .order(created_at: :desc)
      .limit(50)
    
    render json: notifications.map { |n| NotificationSerializer.new(n).as_json }
  end
  
  def update
    notification = current_user.notifications.find(params[:id])
    notification.mark_as_read!
    render json: NotificationSerializer.new(notification).as_json
  end
  
  def destroy
    notification = current_user.notifications.find(params[:id])
    notification.destroy
    render json: { message: 'Notification deleted' }, status: :ok
  end
end

