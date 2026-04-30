class Api::BorderoController < Api::BaseController
  include Authenticable

  def calculate
    result = Bordero::CalculateService.call(params: calculate_params)
    render json: BorderoSerializer.new(result), status: :ok
  end

  private

  def calculate_params
    params.permit(:change_date, :monthly_rate_percent,
                  receivables: [:amount_cents, :due_date, :awaiting_days]).to_h
  end
end
