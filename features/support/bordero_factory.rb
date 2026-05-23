# frozen_string_literal: true
module BorderoFactory
  def create_bordero(change_date:, monthly_rate_percent: 2.5, total_amount_cents: 100000,
                     total_proceeds_cents: 97500, total_interest_amount_cents: 2500,
                     average_days: 30.0, id: nil, user: nil)
    Bordero.create!(
      id:                          id || SecureRandom.uuid,
      change_date:                 Date.parse(change_date.to_s),
      monthly_rate_percent:        monthly_rate_percent,
      total_amount_cents:          total_amount_cents.to_i,
      total_proceeds_cents:        total_proceeds_cents.to_i,
      total_interest_amount_cents: total_interest_amount_cents.to_i,
      average_days:                average_days,
      user:                        user || @current_user
    )
  end
end

World(BorderoFactory)
