class ReviewPolicy < ApplicationPolicy
  def show?;   !record.hidden? || owner? || admin?; end
  def create?
    user.present? && record.booking.present? &&
      record.booking.customer_id == user.id &&
      record.booking.completed? &&
      record.booking.review.nil?
  end
  def update?;  owner? || admin?; end
  def destroy?; admin?; end

  def owner?
    user.present? && record.customer_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user&.admin?
      scope.visible
    end
  end
end
