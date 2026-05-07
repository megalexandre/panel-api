# frozen_string_literal: true
module HolidayOverrides
  class UpdateForm
    include ActiveModel::Model

    PERMITTED_ATTRIBUTES = %i[holiday name].freeze
    attr_accessor(*PERMITTED_ATTRIBUTES)

    validates :holiday, inclusion: { in: [true, false] }, allow_nil: true
    validates :name,    presence: true, if: -> { holiday_cast == true }

    def self.from_params(params)
      new(params.permit(*PERMITTED_ATTRIBUTES))
    end

    def holiday_cast
      return nil if holiday.nil?
      ActiveModel::Type::Boolean.new.cast(holiday)
    end

    def to_attributes
      attrs = {}
      attrs[:holiday] = holiday_cast unless holiday.nil?
      attrs[:name] = name.presence
      attrs.compact
    end
  end
end
