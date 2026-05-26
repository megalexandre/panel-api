# frozen_string_literal: true

class BorderoSavedSerializer
  def initialize(bordero)
    @bordero = bordero
  end

  private

  def receivables_with_breakdown
    ordered = Receivable.unscoped.where(bordero_id: @bordero.id, deleted_at: nil).order(:due_date, :id)
    items   = Bordero::CalculateService.call(params: {
      change_date:          @bordero.change_date.iso8601,
      monthly_rate_percent: @bordero.monthly_rate_percent,
      awaiting_days:        @bordero.awaiting_days,
      receivables:          ordered.map { |r| { amount_cents: r.amount_cents, due_date: r.due_date.iso8601 } }
    })[:items]

    ordered.zip(items).map do |r, item|
      {
        id:                    r.id,
        amount_cents:          r.amount_cents,
        due_date:              r.due_date,
        interest_amount_cents: item[:interest_amount_cents],
        proceeds_cents:        item[:proceeds_cents],
        deposit_date:          item[:deposit_date],
        settlement_date:       item[:settlement_date],
        total_days:            item[:total_days]
      }
    end
  end

  public

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
      receivables:                 receivables_with_breakdown
    }
  end
end
