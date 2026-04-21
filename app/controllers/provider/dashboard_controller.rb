class Provider::DashboardController < Provider::BaseController
  def index
    profile = current_profile
    return redirect_to provider_onboarding_path unless profile&.onboarding_completed?

    @upcoming = profile.bookings.includes(:customer, :service).active.upcoming.order(:start_time).limit(10)
    @pending  = profile.bookings.includes(:customer, :service).where(status: :pending).order(:start_time).limit(10)
    @recent_reviews = profile.reviews.includes(:customer).order(created_at: :desc).limit(5)
    @revenue_cents  = profile.bookings.where(status: :completed).sum(:price_cents)
    @completed_count = profile.bookings.where(status: :completed).count
    @average_rating = profile.average_rating
  end
end
