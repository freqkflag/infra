class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user
  has_one_attached :attachment
  
  validates :content, presence: true, length: { maximum: 5000 }
  
  after_create_commit :broadcast_message
  
  def mark_as_read!
    update(is_read: true, read_at: Time.current)
  end
  
  private
  
  def broadcast_message
    MessageChannel.broadcast_to(conversation, {
      id: id,
      content: content,
      user_id: user_id,
      username: user.username,
      created_at: created_at
    })
  end
end

