# frozen_string_literal: true
require "test_helper"

class MetricsEndpointTest < ActionDispatch::IntegrationTest
  test "should return prometheus metrics at /metrics" do
    get "/metrics"

    assert_response :success
    assert_includes response.content_type, "text/plain"
    assert_includes response.body, "app_process_resident_memory_bytes"
    assert_includes response.body, "app_ruby_heap_live_slots"
    assert_includes response.body, "app_ruby_heap_free_slots"
  end

  test "should return prometheus metrics at /api/metrics" do
    get "/api/metrics"

    assert_response :success
    assert_includes response.content_type, "text/plain"
  end
end
