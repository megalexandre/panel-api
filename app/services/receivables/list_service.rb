module Receivables
  class ListService
    def self.call(with_discarded: false)
      relation = with_discarded ? Receivable.with_discarded : Receivable.active
      relation.order(created_at: :desc)
    end
  end
end
