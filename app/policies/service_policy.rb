class ServicePolicy < ApplicationPolicy
  def show?;   record.active? || owner? || admin?; end
  def create?; user&.provider?; end
  def update?; owner? || admin?; end
  def destroy?; owner? || admin?; end

  def owner?
    user&.provider_profile&.id == record.provider_profile_id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin?
        scope.all
      elsif user&.provider?
        scope.where(provider_profile_id: user.provider_profile&.id).or(scope.active)
      else
        scope.active
      end
    end
  end
end
