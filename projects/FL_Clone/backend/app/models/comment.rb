class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true
  belongs_to :parent, class_name: 'Comment', optional: true
  has_many :replies, class_name: 'Comment', foreign_key: 'parent_id', dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy
  
  validates :content, presence: true, length: { maximum: 5000 }
  
  scope :top_level, -> { where(parent_id: nil) }
end

