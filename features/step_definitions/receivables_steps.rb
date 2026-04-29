Given("the following receivables exist:") do |table|
  table.hashes.each do |row|
    create_receivable(
      amount_cents: row["amount_cents"],
      due_date: row["due_date"],
      status: row.fetch("status", "awaiting")
    )
  end
end

Then("the response should contain {int} receivable(s)") do |count|
  expect(json_response["receivables"].size).to eq(count)
end

Then("the receivables should be ordered by {string} {string}") do |field, direction|
  values = json_response["receivables"].map { |r| r[field] }
  expected = direction == "asc" ? values.sort : values.sort.reverse
  expect(values).to eq(expected)
end
