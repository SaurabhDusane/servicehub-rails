require "rails_helper"

RSpec.describe "Customer bookings", type: :request do
  let(:customer) { create(:user, role: :customer) }
  let(:provider) { create(:provider_profile) }
  let(:service)  { create(:service, provider_profile: provider, instant_booking: true, requires_approval: false) }

  before { sign_in customer }

  it "lists bookings" do
    get customer_bookings_path
    expect(response).to have_http_status(:ok)
  end

  it "creates a booking via the service" do
    t = Time.current.next_week.change(hour: 10, min: 0)
    t += 1.day until (1..5).include?(t.wday)
    expect {
      post customer_bookings_path, params: { service_id: service.id, booking: { start_time: t.iso8601 } }
    }.to change(Booking, :count).by(1)
  end
end
