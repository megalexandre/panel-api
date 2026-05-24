# frozen_string_literal: true

module Receivables
  class FindService
    def self.call(id:, user_id:, with_discarded: false)
      relation = with_discarded ? Receivable.unscoped : Receivable.unscoped.where(deleted_at: nil)
      relation.find_by(id: id, user_id: user_id)
    end
  end
end
