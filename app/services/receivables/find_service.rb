module Receivables
  class FindService
    def self.call(id:)
      Receivable.active.find_by(id: id)
    end
  end
end
