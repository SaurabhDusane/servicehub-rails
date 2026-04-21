# ServiceHub

A production-quality Ruby on Rails marketplace for booking local service providers (haircuts, tutoring, cleaning, photography, personal training, consulting, etc.). Customers discover providers, see real-time availability, book appointments, pay deposits/full amounts via Stripe, and leave reviews. Providers run a studio dashboard to manage services, weekly availability, bookings, and revenue. Admins moderate the platform.

## Highlights

- **Three roles** (Customer, Provider, Admin) with role-based dashboards and policies
- **Double-booking prevention** via a PostgreSQL `EXCLUDE` constraint on `tstzrange` plus a transactional booking service
- **Stripe PaymentIntents** (with a graceful "simulated" mode when keys aren't set)
- **Weekly availability + exception days** with a slot generator honoring buffers and time zones
- **Background jobs** (Sidekiq) for reminders, review requests, auto-expiry of stale pending bookings
- **Pundit policies** on every resource; authorized Sidekiq Web UI
- **Tailwind CSS** UI with Hotwire (Turbo + Stimulus)
- **Full RSpec suite**: models, policies, services, requests, jobs
- **Docker compose** stack + Render blueprint for one-click deploys

## Stack

- Ruby 3.3, Rails 7.1, PostgreSQL 16, Redis 7
- Devise, Pundit, Sidekiq (+ sidekiq-cron), Stripe, Active Storage, FriendlyId, PgSearch, Kaminari, Money-Rails
- Tailwind CSS (tailwindcss-rails), Hotwire (Turbo + Stimulus), SimpleForm
- RSpec, FactoryBot, Faker, Shoulda Matchers, Capybara, WebMock

## Quick start

### With Docker (recommended, no Ruby install needed)

```bash
cp .env.example .env
docker compose up --build
# Then in another shell:
docker compose exec web bin/rails db:seed
```

Visit http://localhost:3000. Default demo logins (password `password1234`):

- Admin: `admin@servicehub.test`
- Customer: `customer@servicehub.test`
- Provider: `provider@servicehub.test`

### Native (Ruby 3.3 + Postgres + Redis)

```bash
bundle install
bin/rails db:setup     # creates DB, runs migrations, seeds
bin/dev                # runs web + tailwind watcher + sidekiq via foreman
```

## Running tests

```bash
bundle exec rspec
```

Covered:

- `spec/models/*` — validations, enums, computed fields
- `spec/policies/booking_policy_spec.rb` — Pundit authorization
- `spec/services/bookings/creator_spec.rb` — double-booking prevention, approval vs instant flows
- `spec/services/availability/checker_spec.rb` — weekly windows, overlap detection
- `spec/requests/*` — end-to-end routes
- `spec/jobs/booking_reminder_scheduler_job_spec.rb` — background job behavior

## Architecture

```
app/
├── controllers/       # REST resources, namespaced /customer, /provider, /admin
├── models/            # ActiveRecord, Devise, FriendlyId, PgSearch
├── policies/          # Pundit per-resource policies
├── services/          # POROs: availability, bookings, payments, notifications
├── jobs/              # Sidekiq: reminders, review requests, auto-expiry
├── mailers/           # BookingMailer + ERB templates
├── views/             # Tailwind UI + Hotwire partials
└── javascript/        # Stimulus controllers
```

Key service objects:

- `Bookings::Creator` — transactional booking creation with Stripe-ready price snapshots
- `Bookings::Canceller` — policy-aware cancellation + partial refunds
- `Availability::Checker` — weekly window + exception + overlap checking
- `Availability::SlotGenerator` — time-zone-aware slot generation for a service+date
- `Payments::Charger` — Stripe PaymentIntent creation, falls back to "simulated" mode in dev
- `Payments::StatusUpdater` / `Payments::Refunder` — webhook-driven status sync

## Payments

Set `STRIPE_SECRET_KEY`, `STRIPE_PUBLISHABLE_KEY`, and `STRIPE_WEBHOOK_SECRET` to enable real payments. Without them, the app automatically runs in simulated mode — the booking flow works end-to-end without touching Stripe. Webhook endpoint: `POST /webhooks/stripe`.

## Background jobs

Sidekiq-cron schedules (see `config/sidekiq_schedule.yml`):

- Every 15 min — send reminder emails for bookings starting in the next 24h
- Hourly — send review-request emails for recently completed bookings
- Every 10 min — auto-reject pending bookings older than 48h

Admin UI for queues: `/sidekiq` (admin-only).

## Deployment

### Render (via Blueprint)

```bash
# Push to a repo, then "New Blueprint" in Render pointing at render.yaml
# Set RAILS_MASTER_KEY + STRIPE_* env vars in the dashboard
```

### Fly.io / Heroku

Standard Rails 7 Dockerfile is included. Provision Postgres + Redis and set:

```
RAILS_MASTER_KEY=...
DATABASE_URL=...
REDIS_URL=...
STRIPE_SECRET_KEY=...
STRIPE_PUBLISHABLE_KEY=...
STRIPE_WEBHOOK_SECRET=...
MAILER_HOST=yourdomain.com
MAILER_FROM=no-reply@yourdomain.com
```

## Feature checklist

- [x] Devise auth with confirmable + trackable
- [x] Role-based routing (customer / provider / admin)
- [x] Provider onboarding flow with avatar/cover upload
- [x] Marketplace: search, category/location/rating/price filters, sorting, pagination
- [x] Provider public profile with reviews and services
- [x] Service listings (instant vs approval, deposit vs full, buffer minutes)
- [x] Weekly availability windows + exception days
- [x] Slot generator with time-zone correctness
- [x] Transactional booking creation; double-booking prevented at DB level
- [x] Stripe PaymentIntent flow + webhook handler
- [x] Partial / full refund handling on cancellation
- [x] Reviews (1 per booking, only if completed)
- [x] Favorites / saved providers
- [x] In-app + email notifications
- [x] Customer / Provider / Admin dashboards
- [x] Admin: users, providers, bookings, reviews, reports, audit log
- [x] Abuse reports + moderation
- [x] Audit log for security-relevant actions
- [x] Sidekiq background jobs + cron schedule
- [x] RSpec tests (models, policies, services, requests, jobs)
- [x] Dockerized (compose), Render blueprint
- [x] Responsive Tailwind UI

## License

MIT
