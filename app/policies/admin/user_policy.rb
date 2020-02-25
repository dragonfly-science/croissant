class Admin::UserPolicy < ApplicationPolicy
  def index?
    user.superadmin?
  end

  def edit?
    user.superadmin?
  end

  def update?
    edit?
  end

  def approve?
    user.superadmin?
  end

  def suspend?
    user.superadmin?
  end

  def reactivate?
    user.superadmin?
  end

  def search?
    user_is_admin_for_consultations? || user.superadmin?
  end
end
