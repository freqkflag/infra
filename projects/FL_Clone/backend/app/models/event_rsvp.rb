class EventRsvp < ApplicationRecord
  belongs_to :user
  belongs_to :event
  
  validates :user_id, uniqueness: { scope: :event_id }
  validates :status, inclusion: { in: 0..2 }
  
  enum status: {
    going: 0,
    maybe: 1,
    not_going: 2
  }
end

