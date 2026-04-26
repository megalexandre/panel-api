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
      post api_receivables_url,
           params: { amount_cents: 2599, due_date: "2026-05-10" },
           headers: auth_headers_for(user)
    end

    assert_response :created
    body = response.parsed_body

    assert_equal "Receivable created successfully", body["message"]
    assert_equal 2599, body["receivable"]["amount_cents"]
    assert_equal "25.99", body["receivable"]["amount"]
    assert_equal "2026-05-10", body["receivable"]["due_date"]
  end

  test "should create receivable from amount with comma" do
    user = create_user(email: "receivables-comma@example.com")

    assert_difference("Receivable.count", 1) do
      post api_receivables_url,
           params: { amount: "12,00", due_date: "2026-05-10" },
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
      post api_receivables_url,
           params: { amount: "12.00", due_date: "2026-05-10" },
           headers: auth_headers_for(user)
    end

    assert_response :created
    body = response.parsed_body

    assert_equal 1200, body["receivable"]["amount_cents"]
    assert_equal "12.00", body["receivable"]["amount"]
  end

  test "should list receivables" do
    user = create_user(email: "receivables-list@example.com")
    Receivable.create!(amount_cents: 1000, due_date: Date.new(2026, 5, 1))
    Receivable.create!(amount_cents: 2000, due_date: Date.new(2026, 6, 1))

    get api_receivables_url, headers: auth_headers_for(user)

    assert_response :ok
    body = response.parsed_body

    assert_equal 2, body["receivables"].size
  end

  test "should return unauthorized when token is missing" do
    get api_receivables_url

    assert_response :unauthorized
    body = response.parsed_body

    assert_equal "Missing authorization token", body["error"]
  end

  test "should soft delete receivable" do
    user = create_user(email: "receivables-delete@example.com")
    receivable = Receivable.create!(amount_cents: 1500, due_date: Date.new(2026, 7, 1))

    delete api_receivable_url(receivable), headers: auth_headers_for(user)

    assert_response :no_content
    assert_not_nil Receivable.unscoped.find(receivable.id).deleted_at
  end

  test "should not list soft deleted receivables" do
    user = create_user(email: "receivables-soft-list@example.com")
    active_receivable = Receivable.create!(amount_cents: 1000, due_date: Date.new(2026, 5, 1))
    deleted_receivable = Receivable.create!(amount_cents: 2000, due_date: Date.new(2026, 6, 1), deleted_at: Time.current)

    get api_receivables_url, headers: auth_headers_for(user)

    assert_response :ok
    ids = response.parsed_body.fetch("receivables").map { |item| item.fetch("id") }

    assert_includes ids, active_receivable.id
    assert_not_includes ids, deleted_receivable.id
  end
end