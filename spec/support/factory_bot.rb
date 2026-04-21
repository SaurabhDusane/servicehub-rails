FactoryBot.define do
  sequence(:email) { |n| "user#{n}@example.test" }

  factory :user do
    email { generate(:email) }
    password { "password1234" }
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    timezone { "UTC" }
    confirmed_at { Time.current }
    role { :customer }

    trait :provider do
      role { :provider }
      after(:create) do |user|
        create(:provider_profile, user: user)
      end
    end

    trait :admin do
      role { :admin }
    end
  end

  factory :provider_profile do
    user { association(:user, role: :provider) }
    business_name { "#{Faker::Company.unique.name} Studio" }
    bio           { Faker::Lorem.paragraph }
    category      { ProviderProfile::CATEGORIES.sample }
    location      { "Austin, TX" }
    service_radius_km { 25 }
    response_time { "within_24h" }
    cancellation_cutoff_hours { 24 }
    status { :active }
    onboarding_completed { true }

    after(:create) do |p|
      (1..5).each do |dow|
        p.availability_windows.create!(day_of_week: dow, start_time: "09:00", end_time: "17:00")
      end
    end
  end

  factory :service do
    provider_profile
    sequence(:name) { |n| "Service #{n}" }
    description { Faker::Lorem.paragraph }
    category { "haircuts" }
    duration_minutes { 60 }
    price_cents { 5_000 }
    deposit_cents { 1_000 }
    currency { "USD" }
    instant_booking { true }
    requires_approval { false }
    active { true }
  end

  factory :availability_window do
    provider_profile
    day_of_week { 1 }
    start_time { "09:00" }
    end_time   { "17:00" }
  end

  factory :booking do
    customer { association(:user, role: :customer) }
    provider_profile
    service { association(:service, provider_profile: provider_profile) }
    start_time { next_weekday_at(10) }
    end_time   { start_time + 60.minutes }
    timezone   { "UTC" }
    price_cents   { 5_000 }
    deposit_cents { 1_000 }
    currency { "USD" }
    status { :pending }
  end

  factory :payment do
    booking
    amount_cents { 5_000 }
    currency { "USD" }
    kind { :full }
    status { :succeeded }
    stripe_payment_intent_id { "pi_test_#{SecureRandom.hex(8)}" }
  end

  factory :review do
    booking { association(:booking, status: :completed, completed_at: 1.day.ago) }
    customer { booking.customer }
    provider_profile { booking.provider_profile }
    rating { 5 }
    body   { "Great experience!" }
  end
end

def next_weekday_at(hour)
  t = Time.current.next_week.change(hour: hour)
  t += 1.day until (1..5).include?(t.wday)
  t
end
