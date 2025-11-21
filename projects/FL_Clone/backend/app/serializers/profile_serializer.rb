class ProfileSerializer < ActiveModel::Serializer
  attributes :id, :bio, :location, :website, :role, :orientation, :interests, :fetishes, :privacy_level, :show_location, :show_age
end

