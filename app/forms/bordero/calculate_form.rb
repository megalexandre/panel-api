# frozen_string_literal: true
module Bordero
  class CalculateForm
    include ActiveModel::Model

    attr_accessor :change_date, :monthly_rate_percent, :receivables

    validates :change_date, presence: true
    validates :monthly_rate_percent, presence: true, numericality: { greater_than: 0 }
    validates :receivables, presence: true
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

        awaiting = item[:awaiting_days]
        if awaiting.nil? || awaiting.to_i < 0
          errors.add("receivables[#{index}].awaiting_days", "must be >= 0")
        end

        begin
          due_date = Date.parse(item[:due_date].to_s)
          effective_start = parsed_change_date + item[:awaiting_days].to_i
          if due_date <= effective_start
            errors.add("receivables[#{index}].due_date", "must be after change_date + awaiting_days")
          end
        rescue ArgumentError
          errors.add("receivables[#{index}].due_date", "is not a valid date")
        end
      end
    end
  end
end
