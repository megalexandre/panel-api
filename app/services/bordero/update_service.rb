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

      form = Bordero::SaveForm.new(@params.slice(:change_date, :monthly_rate_percent, :receivables))
      raise Api::ValidationError.new(form.errors.messages) unless form.valid?

      result = Bordero::CalculateService.call(params: @params)

      ActiveRecord::Base.transaction do
        Receivable.where(bordero_id: bordero.id).update_all(bordero_id: nil)

        if @params[:receivable_ids].present?
          Receivable.where(id: @params[:receivable_ids], user_id: @user_id)
                    .update_all(bordero_id: bordero.id, change_date: @params[:change_date])
        end

        bordero.update!(
          change_date:                 @params[:change_date],
          monthly_rate_percent:        @params[:monthly_rate_percent],
          total_amount_cents:          result[:total_amount_cents],
          total_proceeds_cents:        result[:total_proceeds_cents],
          total_interest_amount_cents: result[:total_interest_amount_cents],
          average_days:                result[:average_days]
        )
      end

      bordero
    end
  end
end
