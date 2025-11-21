class Group < ApplicationRecord
  include PgSearch::Model
  
  belongs_to :user
  has_many :group_memberships, dependent: :destroy
  has_many :members, through: :group_memberships, source: :user
  has_many :group_topics, dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings
  has_many :kink_taggings, as: :taggable, dependent: :destroy
  has_many :kink_tags, through: :kink_taggings
  
  validates :name, presence: true, length: { maximum: 100 }
  validates :slug, presence: true, uniqueness: true
  validates :privacy, inclusion: { in: 0..2 }
  
  before_validation :generate_slug
  
  enum privacy: {
    public: 0,
    private: 1,
    invite_only: 2
  }
  
  pg_search_scope :search_by_name_and_description,
    against: [:name, :description],
    using: {
      tsearch: { prefix: true }
    }
  
  private
  
  def generate_slug
    self.slug ||= name.parameterize if name.present?
  end
end

