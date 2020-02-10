class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :email, presence: true, uniqueness: true, format: { with: /\A[^@]+@[^@]+\z/ }
  validates :role, presence: true

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
end
