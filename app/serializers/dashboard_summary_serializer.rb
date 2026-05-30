# frozen_string_literal: true

class DashboardSummarySerializer
  def initialize(receivables)
    @receivables = receivables
  end

  def as_json(*)
    total_amount_cents = @receivables.sum(:amount_cents)

    {
      total_amount_cents: total_amount_cents,
      total_proceeds_cents: total_amount_cents,
      receivables_count: @receivables.count
    }
  end
end
