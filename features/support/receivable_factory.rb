module ReceivableFactory
  def create_receivable(amount_cents:, due_date:, status: "awaiting", change_date: nil, id: nil)
    Receivable.create!(
      id: id || SecureRandom.uuid,
      amount_cents: amount_cents.to_i,
      due_date: Date.parse(due_date.to_s),
      change_date: change_date ? Date.parse(change_date.to_s) : Date.parse(due_date.to_s),
      status: status
    )
  end
end

World(ReceivableFactory)
