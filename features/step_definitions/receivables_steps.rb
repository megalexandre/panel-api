# frozen_string_literal: true
Given("the following receivables exist:") do |table|
  table.hashes.each do |row|
    create_receivable(
      id: row["id"].presence,
      amount_cents: row["amount_cents"],
      change_date: row["change_date"].presence,
      due_date: row["due_date"],
      status: row.fetch("status", "awaiting"),
      user: @current_user
    )
  end
end

Given("the following receivables exist for the other user:") do |table|
  table.hashes.each do |row|
    create_receivable(
      id: row["id"].presence,
      amount_cents: row["amount_cents"],
      change_date: row["change_date"].presence,
      due_date: row["due_date"],
      status: row.fetch("status", "awaiting"),
      user: @other_user
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
