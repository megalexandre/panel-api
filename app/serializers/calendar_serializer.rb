# frozen_string_literal: true
class CalendarSerializer
  def initialize(days, year:, month:)
    @days  = days
    @year  = year
    @month = month
  end

  def as_json(*)
    { year: @year, month: @month, days: @days }
  end
end
