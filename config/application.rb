# frozen_string_literal: true
require_relative "boot"

require "rails/all"
require "prometheus/middleware/collector"
require "prometheus/middleware/exporter"
require_relative "../lib/app_metrics_middleware"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ApiDashboard
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    config.active_record.schema_format = :sql

    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    # Prometheus: collect HTTP metrics and expose /metrics and /api/metrics endpoints
    config.middleware.use Prometheus::Middleware::Collector
    config.middleware.use ::AppMetricsMiddleware
    config.middleware.use Prometheus::Middleware::Exporter, path: "/metrics"
    config.middleware.use Prometheus::Middleware::Exporter, path: "/api/metrics"
  end
end
