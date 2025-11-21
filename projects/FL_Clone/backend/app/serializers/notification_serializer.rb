class NotificationSerializer < ActiveModel::Serializer
  attributes :id, :type, :message, :is_read, :read_at, :created_at
  
  belongs_to :notifiable
end

