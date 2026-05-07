# frozen_string_literal: true

module Bordero
  module BusinessDayAdjuster
    def self.next_business_day(date)
      date += 1 while date.saturday? || date.sunday? || Calendar::HolidayResolver.holiday?(date)
      date
    end
  end
end
