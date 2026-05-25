# frozen_string_literal: true
class Bordero
  class SaveForm
    include ActiveModel::Model

    PERMITTED_PARAMS = [
      :change_date,
      :monthly_rate_percent,
      :awaiting_days,
      { receivables: [:amount_cents, :due_date, :status] },
      { receivable_ids: [] }
    ].freeze

    attr_accessor :change_date, :monthly_rate_percent, :awaiting_days, :receivables, :receivable_ids

    validates :change_date, presence: true
    validates :monthly_rate_percent, presence: true, numericality: { greater_than: 0 }
    validates :awaiting_days, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :receivables, presence: true, unless: -> { receivable_ids.present? }
    validate :change_date_must_be_valid_date
    validate :receivables_must_be_valid_array

    private

    def change_date_must_be_valid_date
      return if change_date.blank?
      @parsed_change_date = Date.parse(change_date.to_s)
    rescue ArgumentError
      errors.add(:change_date, "is not a valid date")
    end

    def receivables_must_be_valid_array
      return if receivables.blank?

      unless receivables.is_a?(Array) && receivables.any?
        errors.add(:receivables, "must be a non-empty array")
        return
      end

      parsed_change_date = @parsed_change_date
      return if parsed_change_date.nil?

      receivables.each_with_index do |item, index|
        item = item.to_h.with_indifferent_access

        if item[:amount_cents].blank? || item[:amount_cents].to_i <= 0
          errors.add("receivables[#{index}].amount_cents", "must be a positive integer")
        end

        begin
          due_date = Date.parse(item[:due_date].to_s)
          if due_date <= parsed_change_date
            errors.add("receivables[#{index}].due_date", "must be after change_date")
          end
        rescue ArgumentError
          errors.add("receivables[#{index}].due_date", "is not a valid date")
        end
      end
    end
  end
end
