# ServiceHub seed data
# Usage: bin/rails db:seed

require "faker"
Faker::Config.locale = :en

puts "== Seeding ServiceHub =="

def upsert_user(email:, password: "password1234", role:, first_name:, last_name:, timezone: "UTC")
  User.find_or_create_by!(email: email) do |u|
    u.password = password
    u.first_name = first_name
    u.last_name  = last_name
    u.role       = role
    u.timezone   = timezone
    u.confirmed_at = Time.current
  end
end

# ---- Admin ----
admin = upsert_user(
  email: ENV.fetch("ADMIN_EMAIL", "admin@servicehub.test"),
  password: ENV.fetch("ADMIN_PASSWORD", "password1234"),
  role: :admin, first_name: "Ada", last_name: "Admin"
)
puts "Admin: #{admin.email}"

# ---- Demo customers ----
demo_customer = upsert_user(email: "customer@servicehub.test", role: :customer, first_name: "Charlie", last_name: "Customer")
customers = [demo_customer] + 5.times.map do |i|
  upsert_user(
    email: "customer#{i + 1}@servicehub.test",
    role: :customer,
    first_name: Faker::Name.first_name,
    last_name:  Faker::Name.last_name,
    timezone: %w[UTC America/New_York America/Los_Angeles Europe/London].sample
  )
end
puts "Customers: #{customers.size}"

# ---- Demo providers ----
categories = ProviderProfile::CATEGORIES
providers = 8.times.map do |i|
  tz = %w[America/New_York America/Chicago America/Los_Angeles Europe/London Europe/Berlin].sample
  user = upsert_user(
    email: i.zero? ? "provider@servicehub.test" : "provider#{i + 1}@servicehub.test",
    role: :provider,
    first_name: Faker::Name.first_name,
    last_name:  Faker::Name.last_name,
    timezone: tz
  )

  profile = user.provider_profile || user.create_provider_profile!(
    business_name: "#{Faker::Company.unique.name} #{Faker::Company.suffix}",
    bio:           Faker::Company.catch_phrase + ". " + Faker::Lorem.paragraph(sentence_count: 4),
    category:      categories.sample,
    location:      [Faker::Address.city, Faker::Address.state_abbr].join(", "),
    service_radius_km: [10, 25, 50, 100].sample,
    response_time: ProviderProfile::RESPONSE_TIMES.sample,
    cancellation_policy: "Cancel 24h in advance for a full refund.",
    cancellation_cutoff_hours: [12, 24, 48].sample,
    status: :active,
    onboarding_completed: true
  )

  # Weekly availability: Mon–Fri 9–17, Sat 10–14
  (1..5).each do |dow|
    profile.availability_windows.find_or_create_by!(day_of_week: dow) do |w|
      w.start_time = Time.parse("09:00 UTC")
      w.end_time   = Time.parse("17:00 UTC")
    end
  end
  profile.availability_windows.find_or_create_by!(day_of_week: 6) do |w|
    w.start_time = Time.parse("10:00 UTC")
    w.end_time   = Time.parse("14:00 UTC")
  end

  # Services
  2.times do |j|
    profile.services.find_or_create_by!(name: "#{profile.category.humanize} package #{j + 1}") do |s|
      s.description       = Faker::Lorem.paragraph(sentence_count: 3)
      s.category          = profile.category
      s.duration_minutes  = [30, 45, 60, 90].sample
      s.price_cents       = rand(4000..25_000)
      s.deposit_cents     = s.price_cents / 4
      s.currency          = "USD"
      s.instant_booking   = [true, false].sample
      s.requires_approval = !s.instant_booking
      s.active            = true
      s.buffer_minutes    = [0, 10, 15].sample
    end
  end

  profile
end
puts "Providers: #{providers.size}"

# ---- Bookings ----
puts "Creating bookings…"
Booking.destroy_all if Rails.env.development? && Booking.count > 50

providers.each do |provider|
  service = provider.services.active.first
  next unless service

  # Upcoming confirmed booking
  start_time = (Time.current + rand(2..10).days).change(hour: [10, 11, 13, 14, 15].sample, min: 0)
  result = Bookings::Creator.new(
    customer: customers.sample, service: service, start_time: start_time,
    notes: "Looking forward to this!", timezone: provider.user.timezone
  ).call
  if result.success?
    result.booking.update!(status: :confirmed, confirmed_at: Time.current, payment_status: :paid)
  end

  # Completed booking in the past (for review eligibility)
  past_start = (Time.current - rand(5..20).days).change(hour: [10, 11].sample, min: 0)
  past = Booking.new(
    customer: customers.sample, provider_profile: provider, service: service,
    start_time: past_start, end_time: past_start + service.duration_minutes.minutes,
    timezone: provider.user.timezone,
    price_cents: service.price_cents, deposit_cents: service.deposit_cents,
    currency: service.currency, status: :completed, payment_status: :paid,
    completed_at: past_start + 1.hour
  )
  past.save(validate: false)

  # Pending booking
  pend_start = (Time.current + rand(3..15).days).change(hour: 12, min: 0)
  Bookings::Creator.new(
    customer: customers.sample, service: provider.services.active.last || service, start_time: pend_start, timezone: provider.user.timezone
  ).call

  # Review for completed booking
  Review.find_or_create_by!(booking: past) do |r|
    r.customer = past.customer
    r.provider_profile = provider
    r.rating = rand(3..5)
    r.body   = Faker::Restaurant.review
  end
end

ProviderProfile.find_each(&:recalculate_rating!)

# ---- Favorites & notifications ----
customers.each do |c|
  providers.sample(2).each { |p| Favorite.find_or_create_by!(user: c, provider_profile: p) }
  Notifications::Creator.call(user: c, kind: "welcome", title: "Welcome to ServiceHub!", body: "Find and book trusted local pros.")
end

puts "== Done =="
puts "Login options:"
puts "  Admin:    #{admin.email} / password1234"
puts "  Customer: customer@servicehub.test / password1234"
puts "  Provider: provider@servicehub.test / password1234"
