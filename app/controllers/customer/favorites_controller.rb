class Customer::FavoritesController < Customer::BaseController
  def index
    @providers = current_user.favorite_providers.includes(:user).page(params[:page]).per(12)
  end
end
