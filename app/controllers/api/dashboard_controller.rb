# frozen_string_literal: true

class Api::DashboardController < Api::BaseController
  include Authenticable

  before_action :authenticate_request!

  def receivables_by_status
    counts = Receivable
      .where(user: current_user)
      .group(:status)
      .count

    render json: { data: counts.map { |status, count| { status: status, count: count } } }, status: :ok
  end

  def summary
    receivables = Receivable.where(user: current_user)

    render json: DashboardSummarySerializer.new(receivables), status: :ok
  end
end
