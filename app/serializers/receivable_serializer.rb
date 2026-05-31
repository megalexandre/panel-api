# frozen_string_literal: true
class ReceivableSerializer
  def initialize(receivable)
    @receivable = receivable
  end

  def as_json(*)
    {
      id: @receivable.id,
      sequence_number: @receivable.sequence_number,
      amount_cents: @receivable.amount_cents,
      due_date: @receivable.due_date,
      change_date: @receivable.change_date,
      awaiting_days: (@receivable.due_date.to_date - Date.current).to_i,
      status: @receivable.status,
      notes: @receivable.notes,
      created_at: @receivable.created_at,
      deleted_at: @receivable.deleted_at,
      updated_at: @receivable.updated_at
    }
  end
end
