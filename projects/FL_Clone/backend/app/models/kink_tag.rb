class KinkTag < ApplicationRecord
  include PgSearch::Model
  
  has_many :kink_taggings, dependent: :destroy
  has_many :users, through: :kink_taggings, source: :taggable, source_type: 'User'
  has_many :posts, through: :kink_taggings, source: :taggable, source_type: 'Post'
  has_many :groups, through: :kink_taggings, source: :taggable, source_type: 'Group'
  has_many :events, through: :kink_taggings, source: :taggable, source_type: 'Event'
  
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :category, inclusion: { in: %w[bdsm fetish roleplay sensation edgeplay lifestyle other] }, allow_nil: true
  
  before_validation :generate_slug
  
  scope :popular, -> { order(usage_count: :desc) }
  scope :by_category, ->(cat) { where(category: cat) }
  scope :nsfw, -> { where(is_nsfw: true) }
  scope :sfw, -> { where(is_nsfw: false) }
  
  pg_search_scope :search_by_name,
    against: [:name, :description],
    using: {
      tsearch: { prefix: true }
    }
  
  def increment_usage!
    increment!(:usage_count)
  end
  
  def decrement_usage!
    decrement!(:usage_count)
  end
  
  private
  
  def generate_slug
    self.slug ||= name.parameterize if name.present?
  end
end

