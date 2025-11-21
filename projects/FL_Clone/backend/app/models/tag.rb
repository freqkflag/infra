class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :posts, through: :taggings, source: :taggable, source_type: 'Post'
  has_many :events, through: :taggings, source: :taggable, source_type: 'Event'
  has_many :groups, through: :taggings, source: :taggable, source_type: 'Group'
  
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  
  before_validation :generate_slug
  
  private
  
  def generate_slug
    self.slug ||= name.parameterize if name.present?
  end
end

