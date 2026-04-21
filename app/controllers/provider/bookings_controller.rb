class Provider::BookingsController < Provider::BaseController
  before_action :set_booking, only: %i[show update accept reject mark_completed mark_no_show]

  def index
    @bookings = current_profile.bookings.includes(:customer, :service)
                                        .order(start_time: :desc)
                                        .page(params[:page]).per(20)
  end

  def show
    authorize @booking
  end

  def update
    authorize @booking
    redirect_to provider_bookings_path
  end

  def accept
    authorize @booking, :accept?
    @booking.update!(status: :confirmed, confirmed_at: Time.current)
    AuditLog.record!(action: "booking.accepted", user: current_user, target: @booking)
    BookingMailer.confirmation(@booking.id).deliver_later
    redirect_to provider_bookings_path, notice: "Booking confirmed."
  end

  def reject
    authorize @booking, :reject?
    @booking.update!(status: :rejected)
    AuditLog.record!(action: "booking.rejected", user: current_user, target: @booking)
    BookingMailer.cancelled(@booking.id).deliver_later
    redirect_to provider_bookings_path, notice: "Booking rejected."
  end

  def mark_completed
    authorize @booking, :mark_completed?
    @booking.update!(status: :completed, completed_at: Time.current)
    ReviewRequestJob.set(wait: 1.hour).perform_later(@booking.id)
    AuditLog.record!(action: "booking.completed", user: current_user, target: @booking)
    redirect_to provider_bookings_path, notice: "Marked as completed."
  end

  def mark_no_show
    authorize @booking, :mark_no_show?
    @booking.update!(status: :no_show)
    AuditLog.record!(action: "booking.no_show", user: current_user, target: @booking)
    redirect_to provider_bookings_path, notice: "Marked as no-show."
  end

  private

  def set_booking
    @booking = current_profile.bookings.find(params[:id])
  end
end
