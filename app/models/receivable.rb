class Receivable < ApplicationRecord
  scope :active, -> { where(deleted_at: nil) }

  validates :amount_cents, presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :due_date, presence: true

  def soft_delete!
    update!(deleted_at: Time.current)
  end
end