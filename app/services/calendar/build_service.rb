# frozen_string_literal: true
require "holidays"

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
      overrides = HolidayOverride.where(date: days_in_month).index_by(&:date)

      days_in_month
        .select { |date| non_business_day?(date, overrides[date]) }
        .map    { |date| build_day(date, overrides[date]) }
    end

    private

    def non_business_day?(date, override)
      date.saturday? || date.sunday? || resolve_holiday?(date, override)
    end

    def resolve_holiday?(date, override)
      return override.holiday unless override.nil?

      Holidays.on(date, :br).any?
    end

    def days_in_month
      @days_in_month ||= begin
        first = Date.new(@year, @month, 1)
        (first..first.next_month - 1).to_a
      end
    end

    def build_day(date, override)
      info       = resolve_info(date, override)
      is_weekend = date.saturday? || date.sunday?
      {
        date:         date.iso8601,
        weekend:      is_weekend,
        holiday:      info[:holiday],
        holiday_name: info[:name],
        override_id:  override&.id
      }
    end

    def resolve_info(date, override)
      if override
        { holiday: override.holiday, name: override.name }
      else
        gem_holidays = Holidays.on(date, :br)
        { holiday: gem_holidays.any?, name: gem_holidays.first&.fetch(:name, nil) }
      end
    end
  end
end
