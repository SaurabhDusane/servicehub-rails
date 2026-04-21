class NotificationPolicy < ApplicationPolicy
  def index?;  user.present?; end
  def read?;   record.user_id == user&.id; end
  def update?; read?; end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(user_id: user&.id)
    end
  end
end
