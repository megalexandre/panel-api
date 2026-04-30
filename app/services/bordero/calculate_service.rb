module Bordero
  class CalculateService
    def self.call(params:)
      params = params.with_indifferent_access

      form = Bordero::CalculateForm.new(
        change_date: params[:change_date],
        monthly_rate_percent: params[:monthly_rate_percent],
        receivables: params[:receivables]
      )
      raise Api::ValidationError.new(form.errors.messages) unless form.valid?

      change_date = Date.parse(params[:change_date].to_s)
      monthly_rate = params[:monthly_rate_percent].to_f

      items = params[:receivables].map do |item|
        item = item.to_h.with_indifferent_access
        amount_cents  = item[:amount_cents].to_i
        due_date      = Date.parse(item[:due_date].to_s)
        awaiting_days = item[:awaiting_days].to_i

        total_days = (due_date - change_date).to_i - awaiting_days
        rate       = (1 + monthly_rate / 100.0) ** (total_days.to_f / 30.0) - 1

        interest_amount_cents = (amount_cents * rate).round
        proceeds_cents        = amount_cents - interest_amount_cents

        {
          amount_cents:           amount_cents,
          due_date:               item[:due_date],
          total_days:             total_days,
          interest_rate_percent:  (rate * 100).round(4),
          interest_amount_cents:  interest_amount_cents,
          proceeds_cents:         proceeds_cents
        }
      end

      total_amount_cents = items.sum { |i| i[:amount_cents] }
      weighted_days      = items.sum { |i| i[:amount_cents] * i[:total_days] }
      average_days       = (weighted_days.to_f / total_amount_cents).round(2)

      {
        total_amount_cents: total_amount_cents,
        average_days:       average_days,
        items:              items
      }
    end
  end
end
