module Receivables
  class UpdateService
    Result = Struct.new(:receivable, :success?, keyword_init: true)

    def self.call(receivable:, params:)
      success = receivable.update(params)

      Result.new(receivable: receivable, success?: success)
    end
  end
end
