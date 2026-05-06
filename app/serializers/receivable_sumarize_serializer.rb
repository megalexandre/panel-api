# frozen_string_literal: true

# @TODO remover essa query daqui

class ReceivableSumarizeSerializer
  def initialize(receivables)
    @receivables = receivables
  end

  def as_json(*)
    {
      count: @receivables.count,
      total_amount_cents: @receivables.sum(:amount_cents)
    }
  end
end
