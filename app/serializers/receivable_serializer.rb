class ReceivableSerializer
  def initialize(receivable)
    @receivable = receivable
  end

  def as_json(*)
    {
      id: @receivable.id,
      amount_cents: @receivable.amount_cents,
      amount: format("%.2f", @receivable.amount_cents.to_i / 100.0),
      due_date: @receivable.due_date,
      status: @receivable.status,
      created_at: @receivable.created_at,
      deleted_at: @receivable.deleted_at,
      updated_at: @receivable.updated_at
    }
  end
end