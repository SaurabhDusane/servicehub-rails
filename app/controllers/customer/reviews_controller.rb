class Customer::ReviewsController < Customer::BaseController
  before_action :set_booking

  def new
    @review = @booking.build_review(customer: current_user, provider_profile: @booking.provider_profile)
    authorize @review
  end

  def create
    @review = @booking.build_review(review_params.merge(customer: current_user, provider_profile: @booking.provider_profile))
    authorize @review
    if @review.save
      redirect_to customer_booking_path(@booking), notice: "Thanks for your review!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @review = @booking.review
    authorize @review
  end

  def update
    @review = @booking.review
    authorize @review
    if @review.update(review_params)
      redirect_to customer_booking_path(@booking), notice: "Review updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_booking
    @booking = current_user.bookings_as_customer.find(params[:booking_id])
  end

  def review_params
    params.require(:review).permit(:rating, :body, photos: [])
  end
end
