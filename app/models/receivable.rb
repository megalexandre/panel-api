class Receivable < ApplicationRecord
  enum :status, { awaiting: 0, in_analysis: 1, in_transaction: 2, paid: 3, overdue: 4 }

  scope :active, -> { where(deleted_at: nil) }
  scope :discarded, -> { where.not(deleted_at: nil) }
  scope :with_discarded, -> { all }
  scope :with_discarted, -> { with_discarded }

  validates :amount_cents, presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
            
  validates :due_date, presence: true

  def awaiting_days
    return 0 unless due_date
    (due_date - Date.current).to_i
  end

  def soft_delete!
    update!(deleted_at: Time.current)
  end

end