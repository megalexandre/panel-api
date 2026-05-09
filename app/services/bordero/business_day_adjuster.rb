# frozen_string_literal: true

module Bordero
  module BusinessDayAdjuster
    def self.next_business_day(date)
      date += 1 while date.saturday? || date.sunday? || Calendar::HolidayResolver.holiday?(date)
      date
    end

    def self.add_business_days(date, days)
      days.times do
        date += 1
        date += 1 while date.saturday? || date.sunday? || Calendar::HolidayResolver.holiday?(date)
      end
      date
    end
  end
end
