# frozen_string_literal: true

class BorderoSumarizeSerializer
  def initialize(borderos)
    @borderos = borderos
  end

  def as_json(*)
    {
      count:                       @borderos.count,
      total_amount_cents:          @borderos.sum(:total_amount_cents),
      total_proceeds_cents:        @borderos.sum(:total_proceeds_cents),
      total_interest_amount_cents: @borderos.sum(:total_interest_amount_cents)
    }
  end
end
