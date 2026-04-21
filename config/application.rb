require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module ServiceHub
  class Application < Rails::Application
    config.load_defaults 7.1

    config.time_zone = "UTC"
    config.active_job.queue_adapter = :sidekiq
    config.active_record.default_timezone = :utc

    config.autoload_lib(ignore: %w[assets tasks])

    config.generators do |g|
      g.test_framework :rspec,
        fixtures: false,
        view_specs: false,
        helper_specs: false,
        routing_specs: false,
        controller_specs: false,
        request_specs: true
      g.factory_bot dir: "spec/factories"
    end
  end
end
