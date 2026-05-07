# frozen_string_literal: true
module HolidayOverrides
  class CreateForm
    include ActiveModel::Model

    PERMITTED_ATTRIBUTES = %i[date holiday name].freeze
    attr_accessor(*PERMITTED_ATTRIBUTES)

    validates :date,    presence: true
    validates :holiday, inclusion: { in: [true, false] }
    validates :name,    presence: true, if: -> { holiday_cast == true }
    validate  :date_must_be_valid

    def self.from_params(params)
      new(params.permit(*PERMITTED_ATTRIBUTES))
    end

    def holiday_cast
      ActiveModel::Type::Boolean.new.cast(holiday)
    end

    def to_attributes
      { date: date, holiday: holiday_cast, name: name.presence }
    end

    private

    def date_must_be_valid
      return if date.blank?
      Date.parse(date.to_s)
    rescue ArgumentError
      errors.add(:date, "is not a valid date")
    end
  end
end
