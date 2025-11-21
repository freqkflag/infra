class GroupSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :slug, :privacy, :is_active, :created_at
  
  belongs_to :user
  has_many :members
  has_many :kink_tags
end

