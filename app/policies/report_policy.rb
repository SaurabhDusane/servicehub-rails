class ReportPolicy < ApplicationPolicy
  def create?;  user.present?; end
  def index?;   admin?; end
  def show?;    admin?; end
  def update?;  admin?; end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user&.admin?
      scope.where(reporter_id: user&.id)
    end
  end
end
