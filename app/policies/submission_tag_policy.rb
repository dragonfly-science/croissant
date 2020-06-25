class SubmissionTagPolicy < ApplicationPolicy
  def create?
    user_has_consultation_access? && consultation_user_has_access?
  end

  def destroy?
    user_has_consultation_access? && consultation_user_has_access?
  end

  def consultation_user
    consultation = if record.taggable_type == "Submission"
                     record.taggable.consultation
                   else
                     record.taggable&.submission&.consultation
                   end
    ConsultationUser.find_by(user: user, consultation: consultation)
  end
end
