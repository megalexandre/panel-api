When("I send a {word} to {string} with body:") do |method, path, body|
  send(method.downcase, "#{path}", body, @headers)
end

Then("the response status should be {int}") do |status|
  expect(last_response.status).to eq(status)
end

UUID_REGEX = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i
DATE_REGEX = /\A\d{4}-\d{2}-\d{2}(T[\d:.]+Z?)?\z/

Then("the response body should contain:") do |expected_json|
  expected = JSON.parse(expected_json)
  actual   = JSON.parse(last_response.body)

  expected.each do |key, expected_value|
    case expected_value
    when "@uuid"
      expect(actual[key]).to match(UUID_REGEX)
    when "@date"
      expect(actual[key]).to match(DATE_REGEX)
    else
      expect(actual[key]).to eq(expected_value)
    end
  end
end

