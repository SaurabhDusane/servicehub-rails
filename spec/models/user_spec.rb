require "rails_helper"

RSpec.describe User, type: :model do
  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:timezone) }

  describe "#full_name" do
    it "joins first and last name" do
      user = build(:user, first_name: "Jane", last_name: "Doe")
      expect(user.full_name).to eq("Jane Doe")
    end
  end

  describe "roles" do
    it "defaults to customer" do
      expect(User.new.role).to eq("customer")
    end
  end
end
