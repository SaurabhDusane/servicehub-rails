class Customer::BookingsController < Customer::BaseController
  before_action :set_booking, only: %i[show cancel destroy]

  def index
    @bookings = policy_scope(Booking).where(customer_id: current_user.id)
                                     .includes(:service, :provider_profile)
                                     .order(start_time: :desc)
                                     .page(params[:page]).per(15)
  end

  def show
    authorize @booking
  end

  def new
    @provider = ProviderProfile.friendly.find(params[:provider_id])
    @service  = @provider.services.active.find(params[:service_id])
    @start_time = Time.zone.parse(params[:start_time].to_s)
    @booking = Booking.new(
      customer: current_user, provider_profile: @provider, service: @service,
      start_time: @start_time, end_time: @start_time + @service.duration_minutes.minutes,
      price_cents: @service.price_cents, deposit_cents: @service.deposit_cents,
      timezone: current_user.timezone
    )
    authorize @booking
  end

  def create
    service = Service.active.find(params[:service_id] || params.dig(:booking, :service_id))
    result = Bookings::Creator.new(
      customer: current_user,
      service: service,
      start_time: params.dig(:booking, :start_time) || params[:start_time],
      notes: params.dig(:booking, :notes),
      timezone: current_user.timezone
    ).call

    if result.success?
      redirect_to new_customer_booking_payment_path(result.booking), notice: "Booking created. Complete payment to confirm."
    else
      redirect_to provider_service_path(service.provider_profile, service),
                  alert: result.errors.to_sentence.presence || "Could not create booking."
    end
  end

  def cancel
    authorize @booking, :cancel?
    result = Bookings::Canceller.new(booking: @booking, actor: current_user, reason: params[:reason]).call
    if result.success?
      redirect_to customer_booking_path(@booking), notice: refund_notice(result.refund_cents)
    else
      redirect_to customer_booking_path(@booking), alert: result.errors.to_sentence
    end
  end

  def destroy
    authorize @booking
    @booking.destroy if @booking.pending?
    redirect_to customer_bookings_path, notice: "Booking removed."
  end

  private

  def set_booking
    @booking = Booking.find(params[:id])
  end

  def refund_notice(cents)
    return "Booking cancelled." if cents.to_i.zero?
    "Booking cancelled. Refund of #{Money.new(cents).format} is being processed."
  end
end
