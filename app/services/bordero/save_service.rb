# frozen_string_literal: true
class Bordero
  class SaveService
    def self.call(params:, user_id:)
      new(params, user_id).call
    end

    def initialize(params, user_id)
      @params  = params.with_indifferent_access
      @user_id = user_id
    end

    def call
      form = Bordero::SaveForm.new(@params)
      raise Api::ValidationError.new(form.errors.messages) unless form.valid?

      result = Bordero::CalculateService.call(params: @params)

      ActiveRecord::Base.transaction do
        receivables = create_receivables
        bordero     = create_bordero(result)
        receivables.each { |r| r.update!(bordero_id: bordero.id) }
        bordero
      end
    end

    private

    def create_receivables
      @params[:receivables].map do |item|
        item = item.to_h.with_indifferent_access
        Receivable.create!(
          amount_cents: item[:amount_cents],
          due_date:     item[:due_date],
          change_date:  @params[:change_date],
          user_id:      @user_id,
          status:       :awaiting
        )
      end
    end

    def create_bordero(result)
      Bordero.create!(
        user_id:                     @user_id,
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
