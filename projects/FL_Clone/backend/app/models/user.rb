class User < ApplicationRecord
  has_secure_password
  
  has_one :profile, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :groups, foreign_key: :user_id, dependent: :destroy
  has_many :group_memberships, dependent: :destroy
  has_many :member_groups, through: :group_memberships, source: :group
  has_many :events, dependent: :destroy
  has_many :event_rsvps, dependent: :destroy
  has_many :attending_events, through: :event_rsvps, source: :event
  has_many :conversations_as_sender, class_name: 'Conversation', foreign_key: 'sender_id', dependent: :destroy
  has_many :conversations_as_recipient, class_name: 'Conversation', foreign_key: 'recipient_id', dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :active_relationships, class_name: 'Relationship', foreign_key: 'follower_id', dependent: :destroy
  has_many :passive_relationships, class_name: 'Relationship', foreign_key: 'followed_id', dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  has_many :likes, dependent: :destroy
  has_many :media, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :kink_taggings, as: :taggable, dependent: :destroy
  has_many :kink_tags, through: :kink_taggings
  
  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 30 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :birth_date, presence: true
  validate :age_verification
  
  before_create :create_profile
  
  def age
    return nil unless birth_date
    ((Time.zone.now - birth_date.to_time) / 1.year.seconds).floor
  end
  
  def generate_jwt
    JWT.encode({ user_id: id, exp: 7.days.from_now.to_i }, Rails.application.credentials.secret_key_base)
  end
  
  private
  
  def age_verification
    return unless birth_date
    if age < 18
      errors.add(:birth_date, 'must be 18 years or older')
    end
  end
  
  def create_profile
    build_profile
  end
end

