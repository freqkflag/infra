class KinkTagging < ApplicationRecord
  belongs_to :kink_tag
  belongs_to :taggable, polymorphic: true
  
  validates :kink_tag_id, uniqueness: { scope: [:taggable_type, :taggable_id] }
  
  after_create :increment_kink_tag_usage
  after_destroy :decrement_kink_tag_usage
  
  private
  
  def increment_kink_tag_usage
    kink_tag.increment_usage!
  end
  
  def decrement_kink_tag_usage
    kink_tag.decrement_usage!
  end
end

