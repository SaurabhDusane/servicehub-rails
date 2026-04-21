require "rails_helper"

RSpec.describe Review, type: :model do
  it "requires a rating between 1 and 5" do
    review = build(:review, rating: 6)
    expect(review).not_to be_valid
  end

  it "only allows reviews for completed bookings" do
    booking = create(:booking, status: :pending, start_time: 2.days.from_now, end_time: 2.days.from_now + 1.hour)
    review = Review.new(booking: booking, customer: booking.customer, provider_profile: booking.provider_profile, rating: 5, body: "ok")
    expect(review).not_to be_valid
    expect(review.errors[:booking]).to be_present
  end

  it "recalculates provider's average rating after save" do
    booking = create(:booking, status: :completed, completed_at: 1.day.ago)
    create(:review, booking: booking, rating: 4)
    expect(booking.provider_profile.reload.total_reviews).to eq(1)
    expect(booking.provider_profile.average_rating.to_f).to eq(4.0)
  end
end
