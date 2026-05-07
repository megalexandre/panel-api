# frozen_string_literal: true
require "holidays"

module Calendar
  module HolidayResolver
    def self.holiday?(date)
      override = HolidayOverride.find_by(date: date)
      return override.holiday unless override.nil?

      Holidays.on(date, :br).any?
    end

    def self.holiday_info(date)
      override = HolidayOverride.find_by(date: date)
      if override
        return { holiday: override.holiday, name: override.name }
      end

      gem_holidays = Holidays.on(date, :br)
      { holiday: gem_holidays.any?, name: gem_holidays.first&.fetch(:name, nil) }
    end
  end
end
