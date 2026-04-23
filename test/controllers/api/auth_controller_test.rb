require "test_helper"

class Api::AuthControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email: "login-test@example.com",
      password: "password123",
      password_confirmation: "password123",
      roles: ["user"]
    )
  end

  test "should login with valid credentials" do
    post api_auth_login_url, params: {
      email: @user.email,
      password: "password123"
    }

    assert_response :success

    body = response.parsed_body
    assert body["token"].present?
    assert body["refresh_token"].present?
    assert body["expires_at"].present?
  end

  test "should return unauthorized with invalid credentials" do
    post api_auth_login_url, params: {
      email: @user.email,
      password: "wrong-password"
    }

    assert_response :unauthorized

    body = response.parsed_body
    assert_equal ["Invalid email or password"], body["errors"]
  end

  test "should refresh token with valid refresh token" do
    refresh_token = JwtService.encode_refresh(
      user_id: @user.id,
      email: @user.email,
      roles: @user.roles
    )

    post api_auth_refresh_url, params: { refresh_token: refresh_token }

    assert_response :success

    body = response.parsed_body
    assert body["token"].present?
    assert body["refresh_token"].present?
    assert body["expires_at"].present?
  end

  test "should reject refresh with access token" do
    access_token = JwtService.encode(
      user_id: @user.id,
      email: @user.email,
      roles: @user.roles
    )

    post api_auth_refresh_url, params: { refresh_token: access_token }

    assert_response :unauthorized
    assert_equal "Invalid token type", response.parsed_body["error"]
  end

  test "should reject refresh when token is missing" do
    post api_auth_refresh_url

    assert_response :unauthorized
    assert_equal "Missing refresh token", response.parsed_body["error"]
  end
end
