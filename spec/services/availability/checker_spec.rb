require "rails_helper"

RSpec.describe Availability::Checker do
  let(:provider) { create(:provider_profile) }

  it "allows times inside the weekly window" do
    t = Time.current.next_week.change(hour: 10, min: 0)
    t += 1.day until (1..5).include?(t.wday)
    expect(described_class.new(provider).available?(t, t + 1.hour)).to be true
  end

  it "rejects times outside the weekly window" do
    t = Time.current.next_week.change(hour: 23, min: 0)
    t += 1.day until (1..5).include?(t.wday)
    expect(described_class.new(provider).available?(t, t + 1.hour)).to be false
  end

  it "rejects times when there's an existing booking" do
    service = create(:service, provider_profile: provider)
    t = Time.current.next_week.change(hour: 10, min: 0)
    t += 1.day until (1..5).include?(t.wday)
    create(:booking, provider_profile: provider, service: service, start_time: t, end_time: t + 1.hour, status: :confirmed)
    expect(described_class.new(provider).available?(t + 30.minutes, t + 90.minutes)).to be false
  end
end
