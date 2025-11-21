class EmailNotificationJob < ApplicationJob
  queue_as :default
  
  def perform(user_id, notification_type, notifiable_id, notifiable_type)
    user = User.find(user_id)
    notifiable = notifiable_type.constantize.find(notifiable_id)
    
    # Send email notification
    # UserMailer.notification_email(user, notification_type, notifiable).deliver_now
  end
end

