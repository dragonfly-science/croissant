class ConsultationUser < ApplicationRecord
  has_paper_trail
  belongs_to :consultation
  belongs_to :user
  validates :role, presence: true
  validates_uniqueness_of :user_id, scope: %i[consultation_id]

  enum role: {
    viewer: 0,
    editor: 1,
    admin: 2
  }
end
