class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :set_current_time_zone
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  helper_method :current_provider_profile, :stripe_publishable_key

  protect_from_forgery with: :exception

  def current_provider_profile
    current_user&.provider_profile
  end

  def stripe_publishable_key
    Rails.application.config.stripe.publishable_key
  end

  protected

  def configure_permitted_parameters
    extras = %i[first_name last_name phone_number timezone role]
    devise_parameter_sanitizer.permit(:sign_up, keys: extras)
    devise_parameter_sanitizer.permit(:account_update, keys: extras + [:avatar])
  end

  def after_sign_in_path_for(resource)
    case resource.role
    when "admin"    then admin_root_path
    when "provider" then resource.provider_profile&.onboarding_completed? ? provider_root_path : provider_onboarding_path
    else customer_root_path
    end
  end

  def after_sign_up_path_for(resource)
    after_sign_in_path_for(resource)
  end

  private

  def set_current_time_zone(&block)
    tz = current_user&.timezone || "UTC"
    Time.use_zone(tz, &block) if block
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end

  def not_found
    respond_to do |format|
      format.html { render file: Rails.root.join("public/404.html"), status: :not_found, layout: false }
      format.any  { head :not_found }
    end
  end
end
