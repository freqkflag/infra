Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL") { "redis://fl-clone-redis:6379/1" } }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL") { "redis://fl-clone-redis:6379/1" } }
end

