class ProvidersController < ApplicationController
  def show
    @provider = ProviderProfile.friendly.find(params[:id])
    authorize @provider
    @services = @provider.services.active.order(:price_cents)
    @reviews  = @provider.reviews.includes(:customer).order(created_at: :desc).limit(10)
  end
end
