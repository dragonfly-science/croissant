class TagPolicy < ApplicationPolicy
  def create?
    user_has_consultation_access? && consultation_user_has_access?
  end

  def destroy?
    user_has_consultation_access? && consultation_user_has_access?
  end

  def consultation_user
    ConsultationUser.find_by(user: user, consultation: record.taxonomy.consultation)
  end
end
