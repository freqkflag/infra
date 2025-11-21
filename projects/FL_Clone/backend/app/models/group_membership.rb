class GroupMembership < ApplicationRecord
  belongs_to :user
  belongs_to :group
  
  validates :user_id, uniqueness: { scope: :group_id }
  validates :role, inclusion: { in: 0..2 }
  
  enum role: {
    member: 0,
    moderator: 1,
    admin: 2
  }
end

