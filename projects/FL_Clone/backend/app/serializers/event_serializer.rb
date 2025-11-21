class EventSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :start_time, :end_time, :location, :venue, :latitude, :longitude, :privacy, :max_attendees, :is_active, :created_at
  
  belongs_to :user
  has_many :attendees
  has_many :kink_tags
end

