class ConsultationPolicy < ApplicationPolicy
  def index?
    user_is_admin_level?
  end

  def archive?
    user_is_admin_level?
  end

  def restore?
    user_is_admin_level?
  end
end
