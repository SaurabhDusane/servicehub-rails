require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true

  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  config.assume_ssl = true
  config.force_ssl  = true

  config.log_tags = [:request_id]
  config.logger   = ActiveSupport::Logger.new($stdout)
                      .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
                      .then { |logger| ActiveSupport::TaggedLogging.new(logger) }
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  config.cache_store = :redis_cache_store, { url: ENV.fetch("REDIS_URL") }

  config.active_job.queue_adapter = :sidekiq

  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = { host: ENV.fetch("MAILER_HOST", "servicehub.app") }

  config.i18n.fallbacks = true
  config.active_support.report_deprecations = false

  config.active_record.dump_schema_after_migration = false
  config.active_storage.service = :local
end
