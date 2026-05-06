# frozen_string_literal: true
require 'holidays'

module Calendar
  class BuildService
    def self.call(year:, month:)
      new(year, month).call
    end

    def initialize(year, month)
      @year  = year
      @month = month
    end

    def call
      days_in_month.map { |date| build_day(date) }
    end

    private

    def days_in_month
      first = Date.new(@year, @month, 1)
      last  = first.next_month - 1
      (first..last).to_a
    end

    def build_day(date)
      holidays    = Holidays.on(date, :br)
      is_weekend  = date.saturday? || date.sunday?
      is_holiday  = holidays.any?
      {
        date:         date.iso8601,
        weekend:      is_weekend,
        holiday:      is_holiday,
        business_day: !is_weekend && !is_holiday,
        holiday_name: holidays.first&.fetch(:name, nil)
      }
    end
  end
end
