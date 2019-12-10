class Consultation < ApplicationRecord
  enum consultation_type: {
    parliamentary: 0,
    engagement: 1
  }

  validates :name, presence: true
  validates :consultation_type, presence: true, inclusion: { in: consultation_types.keys }

  scope :alpahbetical_order, -> { order("name ASC") }
end
