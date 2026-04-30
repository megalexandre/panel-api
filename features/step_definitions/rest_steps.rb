# frozen_string_literal: true
When("I send a {word} to {string} with body:") do |method, path, body|
  send(method.downcase, "#{path}", body, @headers)
end

When("I send a {word} to {string}") do |method, path|
  send(method.downcase, path, {}, @headers)
end

Then("the response status should be {int}") do |status|
  expect(last_response.status).to eq(status)
end

