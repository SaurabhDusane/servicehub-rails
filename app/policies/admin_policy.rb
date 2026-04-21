class AdminPolicy < ApplicationPolicy
  def dashboard?; admin?; end
  def index?;     admin?; end
  def show?;      admin?; end
  def update?;    admin?; end
  def destroy?;   admin?; end
end
