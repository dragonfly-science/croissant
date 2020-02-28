class Consultation < ApplicationRecord
  has_paper_trail
  has_one :taxonomy, dependent: :destroy
  has_many :submissions, dependent: :destroy

  has_many :consultation_users, dependent: :destroy
  has_many :users, through: :consultation_users

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
  scope :active, -> { where(state: "active") }

  state_machine :state, initial: :active do
    event :archive do
      transition active: :archived
    end
    event :restore do
      transition archived: :active
    end
  end

  def add_user(user, role="viewer")
    ConsultationUser.create(user: user, consultation: self, role: role)
  end
end
