class Provider::OnboardingController < Provider::BaseController
  def show
    @profile = current_user.provider_profile || current_user.build_provider_profile
  end

  def update
    @profile = current_user.provider_profile || current_user.build_provider_profile
    @profile.assign_attributes(profile_params)
    @profile.onboarding_completed = true if @profile.business_name.present? && @profile.category.present? && @profile.bio.present?

    if @profile.save
      redirect_to provider_root_path, notice: "Welcome aboard! Your profile is live once approved."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:provider_profile).permit(
      :business_name, :bio, :category, :location, :service_radius_km, :response_time,
      :cancellation_policy, :cancellation_cutoff_hours, :website, :instagram, :cover_image
    )
  end
end
