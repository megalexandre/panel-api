# frozen_string_literal: true

class Receivable < ApplicationRecord
  belongs_to :user
  belongs_to :bordero, optional: true

  enum :status, { awaiting: 0, to_deposit: 1, deposited: 2, returned: 3, overdue: 4, paid: 5 }

  default_scope { where(deleted_at: nil).where.not(status: :paid) }

  scope :discarded, -> { unscoped.where.not(deleted_at: nil) }
  scope :with_discarded, -> { unscoped }

  validates :amount_cents, presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :due_date, presence: true
  validates :change_date, presence: true
  validates :status, presence: true
  validates :user, presence: true

  def awaiting_days
    return 0 unless due_date
    (due_date - Date.current).to_i
  end

  def soft_delete!
    update!(deleted_at: Time.current)
  end
end
