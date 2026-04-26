module Receivables
  class AmountParser
    def self.to_cents(value)
      normalized = value.to_s.strip.delete(" ").tr(",", ".")
      return nil unless normalized.match?(/\A\d+(\.\d{1,2})?\z/)

      (BigDecimal(normalized) * 100).to_i
    rescue ArgumentError
      nil
    end
  end
end
