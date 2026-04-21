class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def create
    provider = ProviderProfile.friendly.find(params[:provider_id])
    favorite = current_user.favorites.find_or_initialize_by(provider_profile: provider)
    authorize favorite
    favorite.save
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: provider_path(provider) }
    end
  end

  def destroy
    provider = ProviderProfile.friendly.find(params[:provider_id])
    favorite = current_user.favorites.find_by!(provider_profile: provider)
    authorize favorite
    favorite.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: provider_path(provider) }
    end
  end
end
