# frozen_string_literal: true

module Receivables
  class CreateForm
    include ActiveModel::Model

    attr_accessor :amount_cents, :due_date, :status, :change_date

    validates :amount_cents, presence: true
    validates :due_date, presence: true
    validates :change_date, presence: true
    validates :status, presence: true, inclusion: { in: Receivable.statuses.keys }

    def self.from_params(params)
      new(params.require(:receivable).permit(:amount_cents, :due_date, :status, :change_date))
    end

    def to_attributes
      {
        amount_cents: amount_cents,
        due_date: due_date,
        status: status.presence,
        change_date: change_date
      }.compact
    end

  end
end
