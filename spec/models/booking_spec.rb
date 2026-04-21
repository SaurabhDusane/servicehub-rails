require "rails_helper"

RSpec.describe Booking, type: :model do
  it "requires start_time before end_time" do
    booking = build(:booking, start_time: 2.days.from_now, end_time: 1.day.from_now)
    expect(booking).not_to be_valid
    expect(booking.errors[:end_time]).to be_present
  end

  it "rejects past start_time on create" do
    booking = build(:booking, start_time: 1.day.ago, end_time: 1.day.ago + 1.hour)
    expect(booking).not_to be_valid
  end

  describe "#cancellable_by_customer?" do
    it "is true when outside the cutoff" do
      booking = create(:booking, status: :confirmed, start_time: 3.days.from_now, end_time: 3.days.from_now + 1.hour)
      expect(booking.cancellable_by_customer?).to be true
    end

    it "is false within the cutoff window" do
      provider = create(:provider_profile, cancellation_cutoff_hours: 48)
      service  = create(:service, provider_profile: provider)
      start_t  = Time.current + 12.hours
      booking = Booking.create!(customer: create(:user), provider_profile: provider, service: service,
                                start_time: start_t, end_time: start_t + 1.hour, price_cents: service.price_cents,
                                deposit_cents: service.deposit_cents, currency: "USD", status: :confirmed,
                                timezone: "UTC")
      expect(booking.cancellable_by_customer?).to be false
    end
  end
end
