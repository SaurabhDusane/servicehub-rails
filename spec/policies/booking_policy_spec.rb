require "rails_helper"

RSpec.describe BookingPolicy do
  subject { described_class }

  let(:customer) { create(:user, role: :customer) }
  let(:other_user) { create(:user, role: :customer) }
  let(:provider_user) { create(:user, :provider) }
  let(:admin) { create(:user, :admin) }

  let(:booking) do
    create(:booking, customer: customer, provider_profile: provider_user.provider_profile,
                     service: create(:service, provider_profile: provider_user.provider_profile))
  end

  permissions :show? do
    it "allows the customer, provider, and admin" do
      expect(subject).to permit(customer, booking)
      expect(subject).to permit(provider_user, booking)
      expect(subject).to permit(admin, booking)
    end

    it "denies unrelated users" do
      expect(subject).not_to permit(other_user, booking)
    end
  end

  permissions :cancel? do
    it "permits the customer" do
      expect(subject).to permit(customer, booking)
    end
    it "denies strangers" do
      expect(subject).not_to permit(other_user, booking)
    end
  end
end
