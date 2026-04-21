class BookingPolicy < ApplicationPolicy
  def index?;  user.present?; end
  def show?;   participant? || admin?; end
  def create?; user&.customer?; end

  def update?
    admin? || provider_owner?
  end

  def cancel?
    admin? || customer_owner? || provider_owner?
  end

  def accept?;         provider_owner? && record.pending?; end
  def reject?;         provider_owner? && record.pending?; end
  def mark_completed?; (provider_owner? || admin?) && record.confirmed?; end
  def mark_no_show?;   (provider_owner? || admin?) && (record.confirmed? || record.completed?); end

  def destroy?
    customer_owner? && record.pending?
  end

  def customer_owner?
    user.present? && record.customer_id == user.id
  end

  def provider_owner?
    user.present? && user.provider_profile&.id == record.provider_profile_id
  end

  def participant?
    customer_owner? || provider_owner?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user&.admin?
      return scope.none unless user

      if user.provider? && user.provider_profile
        scope.where(provider_profile_id: user.provider_profile.id).or(scope.where(customer_id: user.id))
      else
        scope.where(customer_id: user.id)
      end
    end
  end
end
