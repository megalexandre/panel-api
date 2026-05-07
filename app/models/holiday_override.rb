# frozen_string_literal: true
class HolidayOverride < ApplicationRecord
  validates :date,    presence: true, uniqueness: true
  validates :holiday, inclusion: { in: [true, false] }
  validates :name,    presence: true, if: :holiday?
end
