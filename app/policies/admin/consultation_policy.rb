class Admin::ConsultationPolicy < ApplicationPolicy
  def index?
    user.superadmin? || user_is_admin_for_consultations?
  end

  def edit?
    user.superadmin? || consultation_admin?
  end

  def update?
    edit?
  end

  def archive?
    user.superadmin? || consultation_admin?
  end

  def restore?
    archive?
  end

  def add_user?
    user.superadmin? || consultation_admin?
  end

  private

  def consultation_admin?
    consultation_user = ConsultationUser.find_by(user: user, consultation: record)
    consultation_user&.admin?
  end
end
