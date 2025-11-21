class GroupTopic < ApplicationRecord
  belongs_to :group
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy
  
  validates :title, presence: true, length: { maximum: 200 }
  validates :content, presence: true
  
  scope :pinned, -> { where(is_pinned: true) }
  scope :recent, -> { order(created_at: :desc) }
end

