class ConsultationPolicy < ApplicationPolicy
  def index?
    user
  end

  def show?
    user_can_access_consultation? || user.superadmin?
  end

  def new?
    user_is_not_viewer
  end

  def create?
    new?
  end

  def export?
    user_is_not_viewer && user_can_access_consultation? || user.superadmin?
  end

  def consultation_access?
    user_can_access_consultation? || user.superadmin?
  end

  def consultation_write_access?
    (consultation_access? && consultation_user&.role != "viewer") || user.superadmin?
  end

  private

  def user_is_not_viewer
    user.role != "viewer"
  end

  def user_can_access_consultation?
    consultation_user.present?
  end

  def consultation_user
    ConsultationUser.find_by(user: user, consultation: record)
  end
end
