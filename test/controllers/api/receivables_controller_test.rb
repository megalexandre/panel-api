require "test_helper"

class Api::ReceivablesControllerTest < ActionDispatch::IntegrationTest
  def auth_headers_for(user)
    token = JwtService.encode(
      user_id: user.id,
      email: user.email,
      roles: user.roles
    )

    { "Authorization" => "Bearer #{token}" }
  end

  def create_user(email: "receivables-user@example.com")
    User.create!(
      email: email,
      password: "password123",
      password_confirmation: "password123",
      roles: ["user"]
    )
  end

  test "should create receivable with valid params" do
    user = create_user

    assert_difference("Receivable.count", 1) do
      post receivables_url,
           params: { amount_cents: 2599, due_date: "2026-05-10", status: "awaiting" },
           headers: auth_headers_for(user)
    end

    assert_response :created
    body = response.parsed_body

    assert_equal "Receivable created successfully", body["message"]
    assert_match(/\A[0-9a-f\-]{36}\z/i, body["receivable"]["id"])
    assert_equal 2599, body["receivable"]["amount_cents"]
    assert_equal "25.99", body["receivable"]["amount"]
    assert_equal "2026-05-10", body["receivable"]["due_date"]
  end

  test "should create receivable from amount with comma" do
    user = create_user(email: "receivables-comma@example.com")

    assert_difference("Receivable.count", 1) do
      post receivables_url,
           params: { amount: "12,00", due_date: "2026-05-10", status: "in_analysis" },
           headers: auth_headers_for(user)
    end

    assert_response :created
    body = response.parsed_body

    assert_equal 1200, body["receivable"]["amount_cents"]
    assert_equal "12.00", body["receivable"]["amount"]
  end

  test "should create receivable from amount with dot" do
    user = create_user(email: "receivables-dot@example.com")

    assert_difference("Receivable.count", 1) do
      post receivables_url,
           params: { amount: "12.00", due_date: "2026-05-10", status: "paid" },
           headers: auth_headers_for(user)
    end

    assert_response :created
    body = response.parsed_body

    assert_equal 1200, body["receivable"]["amount_cents"]
    assert_equal "12.00", body["receivable"]["amount"]
  end

  test "should list receivables" do
    user = create_user(email: "receivables-list@example.com")
    Receivable.create!(amount_cents: 1000, due_date: Date.new(2026, 5, 1), status: "awaiting")
    Receivable.create!(amount_cents: 2000, due_date: Date.new(2026, 6, 1), status: "in_analysis")

    get receivables_url, headers: auth_headers_for(user)

    assert_response :ok
    body = response.parsed_body

    assert_equal 2, body["receivables"].size
    assert_equal 1, body.dig("pagination", "current_page")
    assert_equal 20, body.dig("pagination", "per_page")
    assert_equal 1, body.dig("pagination", "total_pages")
    assert_equal 2, body.dig("pagination", "total_count")
  end

  test "should paginate receivables with page and per_page" do
    user = create_user(email: "receivables-pagination@example.com")
    receivable_1 = Receivable.create!(amount_cents: 1000, due_date: Date.new(2026, 5, 1), status: "awaiting")
    receivable_2 = Receivable.create!(amount_cents: 2000, due_date: Date.new(2026, 6, 1), status: "in_analysis")
    receivable_3 = Receivable.create!(amount_cents: 3000, due_date: Date.new(2026, 7, 1), status: "paid")

    get receivables_url,
        params: { page: 2, per_page: 2 },
        headers: auth_headers_for(user)

    assert_response :ok

    body = response.parsed_body
    returned_ids = body.fetch("receivables").map { |item| item.fetch("id") }

    assert_equal [receivable_1.id], returned_ids
    assert_not_includes returned_ids, receivable_2.id
    assert_not_includes returned_ids, receivable_3.id
    assert_equal 2, body.dig("pagination", "current_page")
    assert_equal 2, body.dig("pagination", "per_page")
    assert_equal 2, body.dig("pagination", "total_pages")
    assert_equal 3, body.dig("pagination", "total_count")
  end

  test "should return unauthorized when token is missing" do
    get receivables_url

    assert_response :unauthorized
    body = response.parsed_body

    assert_equal "Missing authorization token", body["error"]
  end

  test "should soft delete receivable" do
    user = create_user(email: "receivables-delete@example.com")
    receivable = Receivable.create!(amount_cents: 1500, due_date: Date.new(2026, 7, 1), status: "awaiting")

    delete receivable_url(receivable), headers: auth_headers_for(user)

    assert_response :no_content
    assert_not_nil Receivable.unscoped.find(receivable.id).deleted_at
  end

  test "should not list soft deleted receivables" do
    user = create_user(email: "receivables-soft-list@example.com")
    active_receivable = Receivable.create!(amount_cents: 1000, due_date: Date.new(2026, 5, 1), status: "awaiting")
    deleted_receivable = Receivable.create!(amount_cents: 2000, due_date: Date.new(2026, 6, 1), status: "paid", deleted_at: Time.current)

    get receivables_url, headers: auth_headers_for(user)

    assert_response :ok
    ids = response.parsed_body.fetch("receivables").map { |item| item.fetch("id") }

    assert_includes ids, active_receivable.id
    assert_not_includes ids, deleted_receivable.id
  end

  test "should list soft deleted receivables with with_discarded" do
    user = create_user(email: "receivables-with-discarded@example.com")
    active_receivable = Receivable.create!(amount_cents: 1000, due_date: Date.new(2026, 5, 1), status: "awaiting")
    deleted_receivable = Receivable.create!(amount_cents: 2000, due_date: Date.new(2026, 6, 1), status: "overdue", deleted_at: Time.current)

    get receivables_url,
        params: { with_discarded: true },
        headers: auth_headers_for(user)

    assert_response :ok
    ids = response.parsed_body.fetch("receivables").map { |item| item.fetch("id") }

    assert_includes ids, active_receivable.id
    assert_includes ids, deleted_receivable.id
  end

  test "should show soft deleted receivable with with_discarded" do
    user = create_user(email: "receivables-show-with-discarded@example.com")
    receivable = Receivable.create!(amount_cents: 3000, due_date: Date.new(2026, 8, 1), status: "in_transaction", deleted_at: Time.current)

    get receivable_url(receivable),
        params: { with_discarded: true },
        headers: auth_headers_for(user)

    assert_response :ok
    assert_equal receivable.id, response.parsed_body.dig("receivable", "id")
  end
end