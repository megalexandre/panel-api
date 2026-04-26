module Receivables
  class CreateService
    Result = Struct.new(:receivable, :success?, keyword_init: true)

    def self.call(params:)
      normalized_params = normalize_amount(params)
      receivable = Receivable.new(normalized_params)
      success = receivable.save

      Result.new(receivable: receivable, success?: success)
    end

    private

    def self.normalize_amount(params)
      params = params.dup
      if params[:amount].present?
        amount_cents = AmountParser.to_cents(params[:amount])
        params[:amount_cents] = amount_cents if amount_cents
      end
      params.except(:amount)
    end
  end
end
