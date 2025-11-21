class Profile < ApplicationRecord
  belongs_to :user
  
  validates :privacy_level, inclusion: { in: 0..3 }
  
  enum privacy_level: {
    public: 0,
    friends: 1,
    private: 2,
    hidden: 3
  }
end

