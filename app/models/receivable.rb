# frozen_string_literal: true

class Receivable < ApplicationRecord
  has_paper_trail only: %i[status amount_cents due_date notes change_date deleted_at]

  belongs_to :user
  belongs_to :bordero, optional: true

  enum :status, draft: "draft", awaiting: "awaiting", to_deposit: "to_deposit",
                deposited: "deposited", returned: "returned", overdue: "overdue", paid: "paid"

  default_scope {
    where(deleted_at: nil).
    where.not(status: [ :paid, :draft ])
  }

  scope :discarded, -> { unscoped.where.not(deleted_at: nil) }
  scope :with_discarded, -> { unscoped }

  before_create :assign_sequence_number

  validates :amount_cents, presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :due_date, presence: true
  validates :change_date, presence: true
  validates :status, presence: true
  validates :user, presence: true

  def soft_delete!
    update!(deleted_at: Time.current)
  end

  private

  def assign_sequence_number
    max = Receivable.unscoped.where(user_id: user_id).maximum(:sequence_number) || 0
    self.sequence_number = max + 1
  end
end
