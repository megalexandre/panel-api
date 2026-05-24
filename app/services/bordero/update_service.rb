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

      form = Bordero::SaveForm.new(@params.slice(:change_date, :monthly_rate_percent, :receivables, :receivable_ids))
      raise Api::ValidationError.new(form.errors.messages) unless form.valid?

      if @params[:receivable_ids].present?
        update_with_receivable_ids(bordero)
      else
        update_with_receivables_array(bordero)
      end

      bordero
    end

    private

    def update_with_receivable_ids(bordero)
      receivables = Receivable.unscoped.where(id: @params[:receivable_ids], user_id: @user_id, deleted_at: nil)
      result = Bordero::CalculateService.call(params: calculate_params_from_records(receivables))

      ActiveRecord::Base.transaction do
        Receivable.where(bordero_id: bordero.id).update_all(bordero_id: nil)
        receivables.update_all(bordero_id: bordero.id, status: "awaiting", change_date: @params[:change_date])
        update_bordero(bordero, result)
      end
    end

    def update_with_receivables_array(bordero)
      result = Bordero::CalculateService.call(params: @params)

      ActiveRecord::Base.transaction do
        Receivable.where(bordero_id: bordero.id).update_all(bordero_id: nil)
        update_bordero(bordero, result)
      end
    end

    def calculate_params_from_records(receivables)
      @params.merge(
        receivables: receivables.map { |r|
          { amount_cents: r.amount_cents, due_date: r.due_date.iso8601, awaiting_days: r.awaiting_days }
        }
      )
    end

    def update_bordero(bordero, result)
      bordero.update!(
        change_date:                 @params[:change_date],
        monthly_rate_percent:        @params[:monthly_rate_percent],
        total_amount_cents:          result[:total_amount_cents],
        total_proceeds_cents:        result[:total_proceeds_cents],
        total_interest_amount_cents: result[:total_interest_amount_cents],
        average_days:                result[:average_days]
      )
    end
  end
end
