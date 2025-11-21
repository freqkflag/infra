class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :email, :is_admin, :created_at
  
  has_one :profile
  has_many :kink_tags
end

