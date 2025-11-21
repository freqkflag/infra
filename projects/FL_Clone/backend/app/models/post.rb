class Post < ApplicationRecord
  include PgSearch::Model
  
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :media, as: :attachable, dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings
  has_many :kink_taggings, as: :taggable, dependent: :destroy
  has_many :kink_tags, through: :kink_taggings
  has_many_attached :images
  
  validates :content, presence: true, length: { maximum: 10000 }
  validates :privacy, inclusion: { in: 0..2 }
  
  enum privacy: {
    public: 0,
    friends: 1,
    private: 2
  }
  
  pg_search_scope :search_by_content,
    against: :content,
    using: {
      tsearch: { prefix: true }
    }
  
  scope :public_posts, -> { where(privacy: :public) }
  scope :for_user, ->(user) { where(user: user).or(where(privacy: :public)) }
end

