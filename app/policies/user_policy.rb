class UserPolicy < ApplicationPolicy
  def index?
    user_is_admin_level?
  end

  def edit?
    user_is_admin_level?
  end

  def approve?
    user_is_admin_level?
  end

  def suspend?
    user_is_admin_level?
  end

  def reactivate?
    user_is_admin_level?
  end

  def update?
    edit?
  end
end
