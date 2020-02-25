class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :consultation_users, dependent: :destroy
  has_many :consultations, through: :consultation_users
  has_many :submission_tags, inverse_of: "tagger", foreign_key: "tagger_id", dependent: :nullify

  validates :email, presence: true, uniqueness: true, format: { with: /\A[^@]+@[^@]+\z/ }
  validates :role, presence: true

  scope :search_by_email, ->(email) { where("email ILIKE ?", "%#{email}%") }

  enum role: {
    viewer: 0,
    editor: 1,
    admin: 2,
    superadmin: 3
  }

  state_machine :state, initial: :pending do
    event :approve do
      transition pending: :active
    end
    event :suspend do
      transition active: :inactive
      transition pending: :on_hold
    end
    event :reactivate do
      transition inactive: :active
      transition on_hold: :pending
    end
  end

  def active_for_authentication?
    super && active?
  end

  def inactive_message
    active? ? super : :not_approved
  end

  def consultation_admin?
    consultation_users.any?(&:admin?)
  end
end
