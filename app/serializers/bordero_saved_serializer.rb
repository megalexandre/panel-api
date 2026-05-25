# frozen_string_literal: true

class BorderoSavedSerializer
  def initialize(bordero)
    @bordero = bordero
  end

  def as_json(*)
    {
      id:                          @bordero.id,
      change_date:                 @bordero.change_date,
      monthly_rate_percent:        @bordero.monthly_rate_percent.to_f,
      awaiting_days:               @bordero.awaiting_days,
      total_amount_cents:          @bordero.total_amount_cents,
      total_proceeds_cents:        @bordero.total_proceeds_cents,
      total_interest_amount_cents: @bordero.total_interest_amount_cents,
      average_days:                @bordero.average_days,
      created_at:                  @bordero.created_at,
      receivables:                 @bordero.receivables.map { |r|
        { id: r.id, amount_cents: r.amount_cents, due_date: r.due_date }
      }
    }
  end
end
