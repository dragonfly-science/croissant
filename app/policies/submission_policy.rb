class SubmissionPolicy < ApplicationPolicy
  def create?
    user_has_consultation_access? && consultation_user_has_access?
  end

  def show?
    user_has_consultation_access?
  end

  def destroy?
    user_has_consultation_access? && consultation_user_has_access?
  end

  def tag?
    user_has_consultation_access? && consultation_user_has_access?
  end

  def edit?
    user_has_consultation_access? && consultation_user_has_access?
  end

  def update?
    edit?
  end

  def mark_process?
    user_has_consultation_access? && consultation_user_has_access?
  end

  def mark_complete?
    user_has_consultation_access? && consultation_user_has_access?
  end

  def mark_reject?
    user_has_consultation_access? && consultation_user_has_access?
  end
end
