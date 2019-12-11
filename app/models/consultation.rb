class Consultation < ApplicationRecord
  has_one :taxonomy, dependent: :destroy

  after_initialize do |consultation|
    consultation.taxonomy ||= Taxonomy.new(consultation: consultation)
  end

  enum consultation_type: {
    parliamentary: 0,
    engagement: 1
  }

  validates :name, presence: true
  validates :consultation_type, presence: true, inclusion: { in: consultation_types.keys }

  scope :alphabetical_order, -> { order("name ASC") }
end
