module Receivables
  class ListService
    def self.call
      Receivable.active.order(created_at: :desc)
    end
  end
end
