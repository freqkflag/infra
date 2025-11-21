require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module FlClone
  class Application < Rails::Application
    config.load_defaults 7.1
    config.api_only = true
    
    config.middleware.use Rack::Cors do
      allow do
        origins '*'
        resource '*',
          headers: :any,
          methods: [:get, :post, :put, :patch, :delete, :options, :head],
          credentials: false
      end
    end
    
    config.active_job.queue_adapter = :sidekiq
    config.action_cable.mount_path = '/cable'
  end
end

