class HomeController < ApplicationController
  def index
    @featured_providers = ProviderProfile.discoverable
                                         .includes(:user, :services)
                                         .order(average_rating: :desc, total_reviews: :desc)
                                         .limit(8)
    @categories = ProviderProfile::CATEGORIES
  end
end
