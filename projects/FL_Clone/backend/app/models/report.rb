class Report < ApplicationRecord
  belongs_to :user
  belongs_to :reportable, polymorphic: true
  
  validates :reason, presence: true, length: { maximum: 1000 }
  validates :status, inclusion: { in: 0..2 }
  
  enum status: {
    pending: 0,
    reviewed: 1,
    resolved: 2
  }
end

