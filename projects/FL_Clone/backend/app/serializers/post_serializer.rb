class PostSerializer < ActiveModel::Serializer
  attributes :id, :content, :privacy, :is_pinned, :likes_count, :comments_count, :created_at
  
  belongs_to :user
  has_many :comments
  has_many :tags
  has_many :kink_tags
end

