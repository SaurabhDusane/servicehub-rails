class Provider::ReviewsController < Provider::BaseController
  def index
    @reviews = current_profile.all_reviews.includes(:customer).order(created_at: :desc).page(params[:page]).per(20)
  end
end
