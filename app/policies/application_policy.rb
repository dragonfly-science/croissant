class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end

  private

  def user_has_consultation_access?
    user.superadmin? || consultation_user.present?
  end

  def consultation_user_has_access?
    user.superadmin? || !consultation_user.viewer?
  end

  def user_is_admin_for_consultations?
    ConsultationUser.where(user: user).any?(&:admin?)
  end

  def consultation_user
    ConsultationUser.find_by(user: user, consultation: record.consultation)
  end
end
