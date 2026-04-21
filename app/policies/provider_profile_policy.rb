class ProviderProfilePolicy < ApplicationPolicy
  def show?
    record.status_active? || owner? || admin?
  end

  def create?
    user&.provider? || (user.present? && record&.user_id == user.id)
  end

  def update?
    owner? || admin?
  end

  def destroy?
    admin?
  end

  def owner?
    user.present? && record.user_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin?
        scope.all
      else
        scope.discoverable
      end
    end
  end
end
