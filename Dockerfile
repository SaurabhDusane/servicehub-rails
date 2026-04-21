ARG RUBY_VERSION=3.3.0
FROM ruby:${RUBY_VERSION}-slim AS base

ARG BUNDLE_WITHOUT=""
ARG RAILS_ENV=development

ENV BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="${BUNDLE_WITHOUT}" \
    RAILS_ENV="${RAILS_ENV}" \
    RAILS_LOG_TO_STDOUT=1 \
    RAILS_SERVE_STATIC_FILES=1

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential libpq-dev libvips curl git pkg-config nodejs && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install gems
COPY Gemfile Gemfile.lock* ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy app
COPY . .

# Precompile bootsnap & assets
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec bootsnap precompile app/ lib/ || true
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile || true

EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]
