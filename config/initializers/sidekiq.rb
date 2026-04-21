redis_url = ENV.fetch("REDIS_URL", "redis://localhost:6379/0")

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end

schedule_file = Rails.root.join("config/sidekiq_schedule.yml")
if File.exist?(schedule_file) && Sidekiq.server?
  require "sidekiq/cron/job"
  Sidekiq::Cron::Job.load_from_hash(YAML.load_file(schedule_file))
end
