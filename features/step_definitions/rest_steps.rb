When("I send a {word} to {string} with body:") do |method, path, body|
  send(method.downcase, "#{path}", body, @headers)
end

Then("the response status should be {int}") do |status|
  expect(last_response.status).to eq(status)
end

