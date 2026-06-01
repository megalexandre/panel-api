# frozen_string_literal: true
class AppMetricsMiddleware
  STATUS_PATH = "/proc/self/status".freeze
  UPDATE_INTERVAL = 30 # seconds

  def initialize(app, registry: Prometheus::Client.registry)
    @app = app
    @last_update = nil
    @memory_rss_bytes = register_gauge(
      registry,
      :app_process_resident_memory_bytes,
      "Resident memory (RSS) used by the Ruby process in bytes"
    )
    @ruby_heap_live_slots = register_gauge(
      registry,
      :app_ruby_heap_live_slots,
      "Current number of live slots in the Ruby VM heap"
    )
    @ruby_heap_free_slots = register_gauge(
      registry,
      :app_ruby_heap_free_slots,
      "Current number of free slots in the Ruby VM heap"
    )
  end

  def call(env)
    update_metrics if metrics_stale?
    @app.call(env)
  end

  private

  def metrics_stale?
    @last_update.nil? || (Process.clock_gettime(Process::CLOCK_MONOTONIC) - @last_update) >= UPDATE_INTERVAL
  end

  def register_gauge(registry, name, docstring)
    registry.gauge(name, docstring: docstring)
  rescue Prometheus::Client::Registry::AlreadyRegisteredError
    registry.get(name)
  end

  def update_metrics
    @memory_rss_bytes.set(read_rss_bytes)

    gc = GC.stat
    @ruby_heap_live_slots.set(gc[:heap_live_slots])
    @ruby_heap_free_slots.set(gc[:heap_free_slots])

    @last_update = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

  def read_rss_bytes
    status = File.read(STATUS_PATH)
    vm_rss_line = status.lines.find { |line| line.start_with?("VmRSS:") }
    return 0 unless vm_rss_line

    value_kb = vm_rss_line.split[1].to_i
    value_kb * 1024
  rescue StandardError
    0
  end
end