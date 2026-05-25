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

Given("the bordero parameters:") do |table|
  params = table.rows_hash
  @bordero_params = {
    change_date:          params["change_date"],
    monthly_rate_percent: params["monthly_rate_percent"].to_f,
    awaiting_days:        params["awaiting_days"].to_i
  }
end

Given("the receivables are:") do |table|
  @bordero_receivables = table.hashes.map do |row|
    { amount_cents: row["amount_cents"].to_i, due_date: row["due_date"] }
  end
end

When("I calculate the bordero") do
  body = @bordero_params.merge(receivables: @bordero_receivables).to_json
  post "/bordero/calculate", body, @headers
end

Then("the bordero totals should be:") do |table|
  coerce = ->(v) { Integer(v) rescue (Float(v) rescue v) }
  actual = json_response

  table.rows_hash.each do |key, expected_value|
    actual_value = actual[key]
    coerced      = coerce.call(expected_value)
    expect(actual_value).to eq(coerced), <<~MSG
      FAILED KEY: "#{key}"
      EXPECTED: #{coerced.inspect}
      GOT:      #{actual_value.inspect}
    MSG
  end
end

Then("the bordero items should be:") do |table|
  coerce       = ->(v) { Integer(v) rescue (Float(v) rescue v) }
  actual_items = json_response["items"]

  table.hashes.each_with_index do |expected, index|
    actual = actual_items[index]
    expected.each do |key, expected_value|
      actual_value = actual[key]
      coerced      = coerce.call(expected_value)
      expect(actual_value).to eq(coerced), <<~MSG
        FAILED ITEM [#{index}] KEY: "#{key}"
        EXPECTED: #{coerced.inspect}
        GOT:      #{actual_value.inspect}
      MSG
    end
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
