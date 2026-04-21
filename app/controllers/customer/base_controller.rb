class Customer::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_customer

  layout "customer"

  private

  def ensure_customer
    return if current_user.customer? || current_user.admin?
    redirect_to root_path, alert: "Customer access required."
  end
end
