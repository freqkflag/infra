class Media < ApplicationRecord
  belongs_to :user
  belongs_to :attachable, polymorphic: true, optional: true
  has_one_attached :file
  
  validates :file_type, presence: true, inclusion: { in: %w[image video] }
  validates :privacy, inclusion: { in: 0..2 }
  
  enum privacy: {
    public: 0,
    friends: 1,
    private: 2
  }
end

