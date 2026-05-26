# frozen_string_literal: true

class Api::CalendarController < Api::BaseController
  include Authenticable

  def index
    return render json: { errors: { year: ["can't be blank"] } }, status: :unprocessable_entity if params[:year].blank?

    year  = params[:year].to_i
    month = params[:month].to_i

    unless (1..12).include?(month)
      return render json: { errors: { month: ["must be between 1 and 12"] } }, status: :unprocessable_entity
    end

    days = Date.new(year, month, 1).upto(Date.new(year, month, -1)).map do |date|
      weekend = date.saturday? || date.sunday?
      holiday = Calendar::HolidayResolver.holiday?(date)
      { date: date.to_s, weekend: weekend, holiday: holiday, business_day: !weekend && !holiday }
    end

    render json: { year: year, month: month, days: days }, status: :ok
  end
end
