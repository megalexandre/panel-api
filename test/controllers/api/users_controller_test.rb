# frozen_string_literal: true
require "test_helper"

class Api::UsersControllerTest < ActionDispatch::IntegrationTest
  test "should create user with valid params" do
    assert_difference("User.count", 1) do
      post users_url, params: {
        email: "new-user@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    end

    assert_response :created

    body = response.parsed_body
    assert_equal "User created successfully", body["message"]
    assert_equal "new-user@example.com", body["user"]["email"]
    assert_equal ["user"], body["user"]["roles"]
  end

  test "should not create user with duplicate email" do
    User.create!(
      email: "existing@example.com",
      password: "password123",
      password_confirmation: "password123",
      roles: ["user"]
    )

    assert_no_difference("User.count") do
      post users_url, params: {
        email: "existing@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    end

    assert_response :unprocessable_entity

    body = response.parsed_body
    assert_includes body["errors"], "Email has already been taken"
  end

  test "should return current user with valid token" do
    user = User.create!(
      email: "me@example.com",
      password: "password123",
      password_confirmation: "password123",
      roles: ["user"]
    )

    token = JwtService.encode(
      user_id: user.id,
      email: user.email,
      roles: user.roles
    )

    get me_users_url, headers: { "Authorization" => "Bearer #{token}" }

    assert_response :success

    body = response.parsed_body
    assert_equal user.id, body["user"]["id"]
    assert_equal user.email, body["user"]["email"]
    assert_equal user.roles, body["user"]["roles"]
  end

  test "should return unauthorized when token is missing" do
    get me_users_url

    assert_response :unauthorized

    body = response.parsed_body
    assert_equal "Missing authorization token", body["error"]
  end
end
