# frozen_string_literal: true
class BorderoSerializer
  def initialize(result)
    @result = result
  end

  def as_json(*)
    {
      total_amount_cents:          @result[:total_amount_cents],
      total_proceeds_cents:        @result[:total_proceeds_cents],
      total_interest_amount_cents: @result[:total_interest_amount_cents],
      average_days:                @result[:average_days],
      items:                @result[:items].map { |item| serialize_item(item) }
    }
  end

  private

  def serialize_item(item)
    {
      amount_cents:          item[:amount_cents],
      deposit_date:          item[:deposit_date],
      settlement_date:       item[:settlement_date],
      total_days:            item[:total_days],
      interest_rate_percent: item[:interest_rate_percent],
      interest_amount_cents: item[:interest_amount_cents],
      proceeds_cents:        item[:proceeds_cents]
    }
  end
end
