# frozen_string_literal: true
module Receivables
  class ChangeStatusService
    VALID_STATUSES = Receivable.statuses.keys.freeze

    Result = Struct.new(:receivable, :success?, :errors, keyword_init: true)

    def self.call(receivable:, status:)
      unless VALID_STATUSES.include?(status.to_s)
        return Result.new(receivable: receivable, success?: false, errors: [ "Status inválido: #{status}" ])
      end

      success = receivable.update(status: status)
      errors = success ? [] : receivable.errors.full_messages

      Result.new(receivable: receivable, success?: success, errors: errors)
    end
  end
end
