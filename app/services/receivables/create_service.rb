module Receivables
  class CreateService
    Result = Struct.new(:receivable, :success?, keyword_init: true)

    def self.call(params:)
      receivable = Receivable.new(params)
      success = receivable.save

      Result.new(receivable: receivable, success?: success)
    end
  end
end
