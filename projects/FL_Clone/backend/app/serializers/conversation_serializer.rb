class ConversationSerializer < ActiveModel::Serializer
  attributes :id, :last_message_at, :created_at, :unread_count
  
  has_one :sender
  has_one :recipient
  has_many :messages
  
  def unread_count
    object.unread_count_for(instance_options[:current_user])
  end
end

