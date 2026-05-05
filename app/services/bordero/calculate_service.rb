# frozen_string_literal: true
module Bordero
  class CalculateService
    
    def self.call(params:)
      new(params).call
    end

    def initialize(params)
      params        = params.with_indifferent_access
      @change_date  = Date.parse(params[:change_date].to_s)
      @monthly_rate = params[:monthly_rate_percent].to_f
      @receivables  = params[:receivables]
    end

    def call
      {
        total_amount_cents: total_amount_cents,
        average_days:       average_days,
        items:              items
      }
    end

    private

    def items
      @items ||= @receivables.map { |r| calculate_item(r) }
    end

    def calculate_item(raw)
      item          = raw.to_h.with_indifferent_access
      amount_cents  = item[:amount_cents].to_i
      due_date      = Date.parse(item[:due_date].to_s)
      awaiting_days = item[:awaiting_days].to_i

      adjusted   = BusinessDayAdjuster.next_business_day(due_date)
      total_days = (adjusted - @change_date).to_i - awaiting_days
      rate       = (1 + @monthly_rate / 100.0) ** (total_days.to_f / 30.0) - 1
      interest   = (amount_cents * rate).round

      {
        amount_cents:          amount_cents,
        due_date:              item[:due_date],
        total_days:            total_days,
        interest_rate_percent: (rate * 100).round(4),
        interest_amount_cents: interest,
        proceeds_cents:        amount_cents - interest
      }
    end

    def total_amount_cents
      @total_amount_cents ||= items.sum { |i| i[:amount_cents] }
    end

    def average_days
      weighted = items.sum { |i| i[:amount_cents] * i[:total_days] }
      (weighted.to_f / total_amount_cents).round(2)
    end
  end
end
