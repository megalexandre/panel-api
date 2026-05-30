# frozen_string_literal: true
require "test_helper"

class Api::DashboardControllerTest < ActionDispatch::IntegrationTest
  def auth_headers_for(user)
    token = JwtService.encode(
      user_id: user.id,
      email: user.email,
      roles: user.roles
    )

    { "Authorization" => "Bearer #{token}" }
  end

  def create_user(email: "dashboard-user@example.com")
    User.create!(
      email: email,
      password: "password123",
      password_confirmation: "password123",
      roles: ["user"]
    )
  end

  test "summary returns totals and count for active receivables" do
    user = create_user

    Receivable.create!(amount_cents: 100_000, due_date: "2026-06-10", change_date: "2026-05-10", status: "awaiting", user: user)
    Receivable.create!(amount_cents: 250_000, due_date: "2026-07-01", change_date: "2026-05-10", status: "to_deposit", user: user)
    # Excluded by default scope (paid/draft) and must not be counted
    Receivable.create!(amount_cents: 999_999, due_date: "2026-06-10", change_date: "2026-05-10", status: "paid", user: user)
    Receivable.create!(amount_cents: 999_999, due_date: "2026-06-10", change_date: "2026-05-10", status: "draft", user: user)

    get dashboard_summary_url, headers: auth_headers_for(user)

    assert_response :ok
    body = response.parsed_body

    assert_equal 350_000, body["total_amount_cents"]
    assert_equal 350_000, body["total_proceeds_cents"]
    assert_equal 2, body["receivables_count"]
  end

  test "summary only considers the current user's receivables" do
    user = create_user(email: "dashboard-owner@example.com")
    other = create_user(email: "dashboard-other@example.com")

    Receivable.create!(amount_cents: 100_000, due_date: "2026-06-10", change_date: "2026-05-10", status: "awaiting", user: user)
    Receivable.create!(amount_cents: 500_000, due_date: "2026-06-10", change_date: "2026-05-10", status: "awaiting", user: other)

    get dashboard_summary_url, headers: auth_headers_for(user)

    assert_response :ok
    body = response.parsed_body

    assert_equal 100_000, body["total_amount_cents"]
    assert_equal 1, body["receivables_count"]
  end

  test "summary returns zeros when there are no active receivables" do
    user = create_user(email: "dashboard-empty@example.com")

    get dashboard_summary_url, headers: auth_headers_for(user)

    assert_response :ok
    body = response.parsed_body

    assert_equal 0, body["total_amount_cents"]
    assert_equal 0, body["total_proceeds_cents"]
    assert_equal 0, body["receivables_count"]
  end

  test "summary requires authentication" do
    get dashboard_summary_url

    assert_response :unauthorized
  end
end
