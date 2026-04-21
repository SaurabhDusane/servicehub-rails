class AvailabilityWindowPolicy < ApplicationPolicy
  def index?;   true; end
  def create?;  owner?; end
  def update?;  owner?; end
  def destroy?; owner?; end

  def owner?
    user&.provider_profile&.id == record.provider_profile_id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user&.admin?
      return scope.none unless user&.provider_profile
      scope.where(provider_profile_id: user.provider_profile.id)
    end
  end
end
