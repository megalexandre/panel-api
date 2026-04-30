# frozen_string_literal: true

module Receivables
  class CreateForm
    include ActiveModel::Model

    PERMITTED_ATTRIBUTES = %i[amount_cents due_date status change_date].freeze
    attr_accessor(*PERMITTED_ATTRIBUTES, :user_id)

    validates :amount_cents, presence: true
    validates :due_date, presence: true
    validates :change_date, presence: true
    validates :status, presence: true, inclusion: { in: Receivable.statuses.keys }
    validates :user_id, presence: true

    def self.from_params(params)
      new(params.require(:receivable).permit(:amount_cents, :due_date, :status, :change_date))
    end

    def to_attributes
      {
        amount_cents: amount_cents,
        due_date: due_date,
        status: status.presence,
        change_date: change_date,
        user_id: user_id
      }.compact
    end

  end
end
