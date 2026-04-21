source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.0"

gem "rails", "~> 7.1.3"
gem "pg", "~> 1.5"
gem "puma", ">= 5.0"

# Assets / Hotwire / Tailwind
gem "sprockets-rails"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails", "~> 2.3"

gem "jbuilder"
gem "bootsnap", require: false
gem "image_processing", "~> 1.2"

# Auth & authorization
gem "devise", "~> 4.9"
gem "pundit", "~> 2.3"

# Background jobs
gem "sidekiq", "~> 7.2"
gem "sidekiq-cron", "~> 1.12"
gem "redis", "~> 5.0"
gem "connection_pool", "~> 2.5"  # pin: 3.x needs Ruby 3.4+

# Payments
gem "stripe", "~> 10.0"

# Pagination, search, money, nice enums
gem "kaminari", "~> 1.2"
gem "ransack", "~> 4.1"
gem "money-rails", "~> 1.15"
gem "pg_search", "~> 2.3"

# Helpers
gem "simple_form", "~> 5.3"
gem "friendly_id", "~> 5.5"

gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  gem "debug"
  gem "rspec-rails", "~> 6.1"
  gem "factory_bot_rails"
  gem "faker"
  gem "dotenv-rails"
end

group :development do
  gem "web-console"
  gem "listen"
  gem "foreman"
  gem "letter_opener"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "shoulda-matchers", "~> 6.0"
  gem "database_cleaner-active_record"
  gem "webmock"
  gem "vcr"
end
