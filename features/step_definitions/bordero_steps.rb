# frozen_string_literal: true
Given("the following borderos exist:") do |table|
  table.hashes.each do |row|
    create_bordero(
      id:                          row["id"].presence,
      change_date:                 row["change_date"],
      monthly_rate_percent:        row.fetch("monthly_rate_percent", 2.5),
      awaiting_days:               row.fetch("awaiting_days", 2),
      total_amount_cents:          row.fetch("total_amount_cents", 100000),
      total_proceeds_cents:        row.fetch("total_proceeds_cents", 97500),
      total_interest_amount_cents: row.fetch("total_interest_amount_cents", 2500),
      average_days:                row.fetch("average_days", 30.0)
    )
  end
end

Given("the following borderos exist for the other user:") do |table|
  table.hashes.each do |row|
    create_bordero(
      id:                          row["id"].presence,
      change_date:                 row["change_date"],
      monthly_rate_percent:        row.fetch("monthly_rate_percent", 2.5),
      awaiting_days:               row.fetch("awaiting_days", 2),
      total_amount_cents:          row.fetch("total_amount_cents", 100000),
      total_proceeds_cents:        row.fetch("total_proceeds_cents", 97500),
      total_interest_amount_cents: row.fetch("total_interest_amount_cents", 2500),
      average_days:                row.fetch("average_days", 30.0),
      user:                        @other_user
    )
  end
end

Then("the response should contain {int} bordero(s)") do |count|
  expect(json_response["items"].size).to eq(count)
end

Then("the borderos should be ordered by {string} {string}") do |field, direction|
  values = json_response["items"].map { |b| b[field] }
  expected = direction == "asc" ? values.sort : values.sort.reverse
  expect(values).to eq(expected)
end
