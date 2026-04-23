require "prometheus/client"

# Use a thread-safe registry backed by in-process memory
prometheus = Prometheus::Client.registry

# Custom application metrics (add more as needed)
# Example: http_requests_total is already collected by the Rack middleware
prometheus.counter(
  :app_exceptions_total,
  docstring: "Total number of unhandled exceptions raised by the app",
  labels: %i[controller action]
)
