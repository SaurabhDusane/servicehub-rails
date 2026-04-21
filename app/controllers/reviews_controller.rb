class ReviewsController < ApplicationController
  def index
    @provider = ProviderProfile.friendly.find(params[:provider_id])
    @reviews = policy_scope(@provider.all_reviews).includes(:customer).order(created_at: :desc).page(params[:page]).per(20)
  end
end
