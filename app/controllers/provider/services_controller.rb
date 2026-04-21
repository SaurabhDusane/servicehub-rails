class Provider::ServicesController < Provider::BaseController
  before_action :set_service, only: %i[show edit update destroy]

  def index
    @services = current_profile.services.order(created_at: :desc)
  end

  def new
    @service = current_profile.services.build
    authorize @service
  end

  def create
    @service = current_profile.services.build(service_params)
    authorize @service
    if @service.save
      redirect_to provider_services_path, notice: "Service created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show; end
  def edit; end

  def update
    if @service.update(service_params)
      redirect_to provider_services_path, notice: "Service updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @service.update(active: false)
    redirect_to provider_services_path, notice: "Service deactivated."
  end

  private

  def set_service
    @service = current_profile.services.find(params[:id])
    authorize @service
  end

  def service_params
    params.require(:service).permit(
      :name, :description, :category, :duration_minutes, :price_cents, :deposit_cents,
      :currency, :instant_booking, :requires_approval, :active, :buffer_minutes, images: []
    )
  end
end
