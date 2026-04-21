class Customer::PaymentsController < Customer::BaseController
  before_action :set_booking

  def new
    authorize @booking, :show?
    kind = @booking.deposit_cents.positive? && @booking.deposit_cents < @booking.price_cents ? :deposit : :full
    result = Payments::Charger.new(booking: @booking, kind: kind).call
    if result.success?
      @payment = result.payment
      @client_secret = result.client_secret
    else
      redirect_to customer_booking_path(@booking), alert: result.errors.to_sentence
    end
  end

  def create
    authorize @booking, :show?
    # Customer confirms payment via Stripe.js. Webhook will mark success asynchronously.
    # For simulated mode, the Charger already marked succeeded.
    redirect_to customer_booking_path(@booking), notice: "Payment received. We emailed your receipt."
  end

  private

  def set_booking
    @booking = current_user.bookings_as_customer.find(params[:booking_id])
  end
end
