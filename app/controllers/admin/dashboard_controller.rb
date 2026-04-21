class Admin::DashboardController < Admin::BaseController
  def index
    @total_users     = User.count
    @total_providers = ProviderProfile.count
    @total_bookings  = Booking.count
    @gross_revenue_cents = Booking.where(status: :completed).sum(:price_cents)
    @pending_reports = Report.where(status: %i[open investigating]).count
    @flagged_reviews = Review.where(hidden: true).count
    @top_categories  = ProviderProfile.group(:category).order(Arel.sql("count_all DESC")).count
    @recent_activity = AuditLog.includes(:user).order(created_at: :desc).limit(20)
  end
end
