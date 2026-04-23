class AppMetricsMiddleware
  STATUS_PATH = "/proc/self/status".freeze

  def initialize(app, registry: Prometheus::Client.registry)
    @app = app
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
    update_metrics
    @app.call(env)
  end

  private

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