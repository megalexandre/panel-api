# frozen_string_literal: true
require 'holidays'

module Bordero
  module BusinessDayAdjuster
    def self.next_business_day(date)
      date += 1 while date.saturday? || date.sunday? || Holidays.on(date, :br).any?
      date
    end
  end
end
