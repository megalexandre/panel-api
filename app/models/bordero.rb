# frozen_string_literal: true

class Bordero < ApplicationRecord
  belongs_to :user
  has_many :receivables

  before_create :assign_sequence_number

  private

  def assign_sequence_number
    max = Bordero.where(user_id: user_id).maximum(:sequence_number) || 0
    self.sequence_number = max + 1
  end
end
