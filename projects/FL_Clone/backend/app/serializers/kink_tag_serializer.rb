class KinkTagSerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :description, :category, :usage_count, :is_nsfw, :created_at
end

