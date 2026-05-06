# frozen_string_literal: true
require "test_helper"

class Calendar::BuildServiceTest < ActiveSupport::TestCase
  test "returns one entry per day in February (non-leap)" do
    assert_equal 28, Calendar::BuildService.call(year: 2026, month: 2).size
  end

  test "returns 29 days for leap year February" do
    assert_equal 29, Calendar::BuildService.call(year: 2024, month: 2).size
  end

  test "returns 31 days for January" do
    assert_equal 31, Calendar::BuildService.call(year: 2026, month: 1).size
  end

  test "each day has all required keys" do
    day = Calendar::BuildService.call(year: 2026, month: 5).first
    assert_includes day.keys, :date
    assert_includes day.keys, :weekend
    assert_includes day.keys, :holiday
    assert_includes day.keys, :business_day
    assert_includes day.keys, :holiday_name
  end

  test "date field is ISO8601 formatted" do
    day = Calendar::BuildService.call(year: 2026, month: 5).first
    assert_match(/\A\d{4}-\d{2}-\d{2}\z/, day[:date])
  end

  test "Saturday is a weekend and not a business day" do
    # 2026-05-02 is a Saturday
    days = Calendar::BuildService.call(year: 2026, month: 5)
    sat  = days.find { |d| d[:date] == "2026-05-02" }
    assert sat[:weekend]
    assert_not sat[:business_day]
  end

  test "Sunday is a weekend and not a business day" do
    # 2026-05-03 is a Sunday
    days = Calendar::BuildService.call(year: 2026, month: 5)
    sun  = days.find { |d| d[:date] == "2026-05-03" }
    assert sun[:weekend]
    assert_not sun[:business_day]
  end

  test "Tiradentes is a holiday and not a business day" do
    days = Calendar::BuildService.call(year: 2026, month: 4)
    day  = days.find { |d| d[:date] == "2026-04-21" }
    assert day[:holiday]
    assert_not day[:business_day]
    assert_not_nil day[:holiday_name]
  end

  test "regular weekday is a business day with no holiday name" do
    # 2026-05-04 is a Monday with no holiday
    days = Calendar::BuildService.call(year: 2026, month: 5)
    mon  = days.find { |d| d[:date] == "2026-05-04" }
    assert_not mon[:weekend]
    assert_not mon[:holiday]
    assert mon[:business_day]
    assert_nil mon[:holiday_name]
  end
end
