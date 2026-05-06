# frozen_string_literal: true
module Calendar
  class IndexForm
    include ActiveModel::Model

    PERMITTED_PARAMS = %i[year month].freeze
    attr_accessor :year, :month

    validates :year,  presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1970, less_than_or_equal_to: 2100 }
    validates :month, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1,    less_than_or_equal_to: 12 }

    def self.from_params(params)
      new(params.permit(*PERMITTED_PARAMS))
    end

    def year_i  = year.to_i
    def month_i = month.to_i
  end
end
