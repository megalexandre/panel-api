class ReceivableSerializer
  def initialize(receivable)
    @receivable = receivable
  end

  def as_json(*)
    {
      id: @receivable.id,
      amount_cents: @receivable.amount_cents,
      due_date: @receivable.due_date,
      status: @receivable.status,
      created_at: @receivable.created_at,
      deleted_at: @receivable.deleted_at,
      updated_at: @receivable.updated_at
    }
  end
end