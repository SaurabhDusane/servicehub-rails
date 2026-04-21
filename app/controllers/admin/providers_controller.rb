class Admin::ProvidersController < Admin::BaseController
  def index
    @providers = ProviderProfile.includes(:user).order(created_at: :desc).page(params[:page]).per(25)
  end

  def show
    @provider = ProviderProfile.find(params[:id])
  end

  def update
    @provider = ProviderProfile.find(params[:id])
    authorize @provider
    @provider.update!(status: params[:status]) if ProviderProfile.statuses.key?(params[:status])
    AuditLog.record!(action: "provider.status_changed", user: current_user, target: @provider, payload: { status: @provider.status })
    redirect_to admin_provider_path(@provider), notice: "Provider status updated."
  end
end
