class Provider::ProfilesController < Provider::BaseController
  before_action :set_profile

  def show; end
  def edit; end

  def update
    if @profile.update(profile_params)
      redirect_to provider_profile_path, notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_profile
    @profile = current_profile
    authorize @profile
  end

  def profile_params
    params.require(:provider_profile).permit(
      :business_name, :bio, :category, :location, :service_radius_km, :response_time,
      :cancellation_policy, :cancellation_cutoff_hours, :website, :instagram, :cover_image, gallery: []
    )
  end
end
