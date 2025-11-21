class Event < ApplicationRecord
  include PgSearch::Model
  
  belongs_to :user
  has_many :event_rsvps, dependent: :destroy
  has_many :attendees, through: :event_rsvps, source: :user
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings
  has_many :kink_taggings, as: :taggable, dependent: :destroy
  has_many :kink_tags, through: :kink_taggings
  has_one_attached :cover_image
  
  validates :title, presence: true, length: { maximum: 200 }
  validates :start_time, presence: true
  validates :privacy, inclusion: { in: 0..2 }
  validate :end_time_after_start_time
  
  enum privacy: {
    public: 0,
    friends: 1,
    private: 2
  }
  
  pg_search_scope :search_by_title_and_description,
    against: [:title, :description],
    using: {
      tsearch: { prefix: true }
    }
  
  scope :upcoming, -> { where('start_time > ?', Time.current) }
  scope :past, -> { where('start_time <= ?', Time.current) }
  
  private
  
  def end_time_after_start_time
    return unless end_time && start_time
    if end_time < start_time
      errors.add(:end_time, 'must be after start time')
    end
  end
end

