class TaxonomyPolicy < ApplicationPolicy
  def show?
    user_has_consultation_access?
  end

  def upload?
    user_has_consultation_access? && consultation_user_has_access?
  end
end
