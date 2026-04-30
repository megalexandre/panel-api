# frozen_string_literal: true
module Receivables
  class DestroyService
    def self.call(receivable:)
      receivable.soft_delete!
    end
  end
end
