module Receivables
  class FindService
    def self.call(id:, with_discarded: false)
      relation = with_discarded ? Receivable.with_discarded : Receivable.active
      relation.find_by(id: id)
    end
  end
end
