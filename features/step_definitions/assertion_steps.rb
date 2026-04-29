UUID_REGEX = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i
DATE_REGEX = /\A\d{4}-\d{2}-\d{2}(T[\d:.]+Z?)?\z/

Then("the response body should contain:") do |expected_json|
  expected = JSON.parse(expected_json)
  actual   = JSON.parse(last_response.body)

  expected.each do |key, expected_value|
    actual_value = actual[key]
    
    # Criamos uma mensagem de erro customizada que inclui o JSON completo recebido
    error_message = <<~MSG
      FAILED KEY: "#{key}"
      EXPECTED: #{expected_value.inspect}
      GOT:      #{actual_value.inspect}
      
      FULL RESPONSE BODY:
      #{JSON.pretty_generate(actual)}
    MSG

    case expected_value
    when "@uuid"
      expect(actual_value).to match(UUID_REGEX), error_message
    when "@date"
      expect(actual_value).to match(DATE_REGEX), error_message
    else
      expect(actual_value).to eq(expected_value), error_message
    end
  end
end