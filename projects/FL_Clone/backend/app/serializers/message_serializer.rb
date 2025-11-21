class MessageSerializer < ActiveModel::Serializer
  attributes :id, :content, :is_read, :read_at, :created_at
  
  belongs_to :user
end

