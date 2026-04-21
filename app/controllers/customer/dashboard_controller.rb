class Customer::DashboardController < Customer::BaseController
  def index
    @upcoming = current_user.bookings_as_customer.includes(:service, :provider_profile).upcoming.order(:start_time).limit(5)
    @past     = current_user.bookings_as_customer.includes(:service, :provider_profile).past.order(start_time: :desc).limit(5)
    @favorites = current_user.favorite_providers.limit(6)
    @notifications = current_user.notifications.recent.limit(5)
  end
end
