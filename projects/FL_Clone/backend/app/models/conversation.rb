class Conversation < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  has_many :messages, dependent: :destroy
  
  validates :sender_id, uniqueness: { scope: :recipient_id }
  
  def other_user(user)
    user == sender ? recipient : sender
  end
  
  def unread_count_for(user)
    messages.where.not(user: user).where(is_read: false).count
  end
end

