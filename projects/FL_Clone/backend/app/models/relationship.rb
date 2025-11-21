class Relationship < ApplicationRecord
  belongs_to :follower, class_name: 'User'
  belongs_to :followed, class_name: 'User'
  
  validates :follower_id, uniqueness: { scope: :followed_id }
  validate :cannot_follow_self
  
  enum status: {
    following: 0,
    blocked: 1
  }
  
  private
  
  def cannot_follow_self
    if follower_id == followed_id
      errors.add(:follower_id, 'cannot follow yourself')
    end
  end
end

