class Provider::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_provider

  layout "provider"

  helper_method :current_profile

  def current_profile
    @current_profile ||= current_user.provider_profile
  end

  private

  def ensure_provider
    return if current_user.provider? || current_user.admin?
    redirect_to root_path, alert: "Provider access required."
  end
end
