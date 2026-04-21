require "rails_helper"

RSpec.describe "Marketplace", type: :request do
  it "renders the landing page" do
    get "/"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("ServiceHub")
  end

  it "renders the marketplace index" do
    create(:provider_profile)
    get "/marketplace"
    expect(response).to have_http_status(:ok)
  end

  it "filters by category" do
    create(:provider_profile, category: "haircuts")
    get "/marketplace", params: { category: "haircuts" }
    expect(response).to have_http_status(:ok)
  end
end
