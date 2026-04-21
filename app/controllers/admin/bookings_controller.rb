class Admin::BookingsController < Admin::BaseController
  def index
    @bookings = Booking.includes(:customer, :provider_profile, :service)
                       .order(created_at: :desc).page(params[:page]).per(25)
  end

  def show
    @booking = Booking.find(params[:id])
  end
end
