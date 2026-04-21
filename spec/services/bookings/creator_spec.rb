require "rails_helper"

RSpec.describe Bookings::Creator do
  let(:customer) { create(:user, role: :customer) }
  let(:provider) { create(:provider_profile) }
  let(:service)  { create(:service, provider_profile: provider, duration_minutes: 60, instant_booking: true, requires_approval: false) }
  let(:start_at) do
    t = Time.current.next_week.change(hour: 10, min: 0)
    t += 1.day until (1..5).include?(t.wday)
    t
  end

  it "creates a confirmed booking for instant-booking services" do
    result = described_class.new(customer: customer, service: service, start_time: start_at, timezone: "UTC").call
    expect(result).to be_success
    expect(result.booking).to be_confirmed
  end

  it "prevents overlapping bookings" do
    described_class.new(customer: customer, service: service, start_time: start_at, timezone: "UTC").call
    result2 = described_class.new(customer: create(:user), service: service, start_time: start_at + 30.minutes, timezone: "UTC").call
    expect(result2).not_to be_success
    expect(result2.errors.join).to match(/overlap|availability/i)
  end

  it "puts approval-required services into pending state" do
    approval = create(:service, provider_profile: provider, duration_minutes: 60, instant_booking: false, requires_approval: true)
    result = described_class.new(customer: customer, service: approval, start_time: start_at + 2.hours, timezone: "UTC").call
    expect(result.booking).to be_pending
  end
end
