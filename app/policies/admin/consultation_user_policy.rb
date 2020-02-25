class Admin::ConsultationUserPolicy < ApplicationPolicy
  def destroy?
    user.superadmin? || consultation_admin?
  end

  private

  def consultation_admin?
    consultation_user = ConsultationUser.find_by(user: user, consultation: record.consultation)
    consultation_user&.admin?
  end
end
