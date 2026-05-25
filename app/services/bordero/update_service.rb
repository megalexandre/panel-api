# frozen_string_literal: true
class Bordero
  class UpdateService
    def self.call(id:, params:, user_id:)
      new(id, params, user_id).call
    end

    def initialize(id, params, user_id)
      @id      = id
      @params  = params.with_indifferent_access
      @user_id = user_id
    end

    def call
      bordero = Bordero.find_by(id: @id, user_id: @user_id)
      raise Api::ResourceNotFoundError unless bordero

      form = Bordero::SaveForm.new(@params.slice(:change_date, :monthly_rate_percent, :awaiting_days, :receivables, :receivable_ids))
      raise Api::ValidationError.new(form.errors.messages) unless form.valid?

      existing = fetch_existing_receivables
      result   = Bordero::CalculateService.call(params: merged_calculate_params(existing))

      ActiveRecord::Base.transaction do
        Receivable.where(bordero_id: bordero.id).update_all(bordero_id: nil)
        existing.update_all(bordero_id: bordero.id, status: "awaiting", change_date: @params[:change_date]) if existing.present?
        create_and_link_inline_receivables(bordero)
        update_bordero(bordero, result)
      end

      bordero.reload
    end

    private

    def fetch_existing_receivables
      ids = Array(@params[:receivable_ids]).compact.presence
      return Receivable.none unless ids

      Receivable.unscoped.where(id: ids, user_id: @user_id, deleted_at: nil)
    end

    def merged_calculate_params(existing)
      from_db    = existing.map { |r| { amount_cents: r.amount_cents, due_date: r.due_date.iso8601 } }
      from_input = Array(@params[:receivables]).map(&:to_h)

      @params.merge(receivables: from_db + from_input)
    end

    def create_and_link_inline_receivables(bordero)
      Array(@params[:receivables]).each do |item|
        item = item.to_h.with_indifferent_access
        Receivable.create!(
          amount_cents: item[:amount_cents],
          due_date:     item[:due_date],
          change_date:  @params[:change_date],
          bordero_id:   bordero.id,
          user_id:      @user_id,
          status:       :awaiting
        )
      end
    end

    def update_bordero(bordero, result)
      bordero.update!(
        change_date:                 @params[:change_date],
        monthly_rate_percent:        @params[:monthly_rate_percent],
        awaiting_days:               @params[:awaiting_days].to_i,
        total_amount_cents:          result[:total_amount_cents],
        total_proceeds_cents:        result[:total_proceeds_cents],
        total_interest_amount_cents: result[:total_interest_amount_cents],
        average_days:                result[:average_days]
      )
    end
  end
end
