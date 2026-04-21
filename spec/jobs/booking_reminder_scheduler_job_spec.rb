require "rails_helper"

RSpec.describe BookingReminderSchedulerJob, type: :job do
  it "enqueues reminder emails for confirmed bookings within 24h" do
    provider = create(:provider_profile)
    service  = create(:service, provider_profile: provider)
    t = 2.hours.from_now
    booking = Booking.create!(customer: create(:user), provider_profile: provider, service: service,
                              start_time: t, end_time: t + 1.hour,
                              price_cents: service.price_cents, deposit_cents: service.deposit_cents,
                              currency: "USD", status: :confirmed, timezone: "UTC")
    expect {
      described_class.new.perform
    }.to change { ActionMailer::Base.deliveries.size + ActiveJob::Base.queue_adapter.enqueued_jobs.size }.by_at_least(1)
    expect(booking.reload.reminder_sent_at).to be_present
  end
end
