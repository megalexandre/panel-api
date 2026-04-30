# frozen_string_literal: true
Given("I am authenticated as a user") do
  @current_user = User.create!(
    email: "cucumber-user@example.com",
    password: "password123",
    password_confirmation: "password123",
    roles: [ "user" ]
  )
  @headers = auth_headers_for(@current_user)
end

Given("there is another user") do
  @other_user = User.create!(
    email: "cucumber-other-user@example.com",
    password: "password123",
    password_confirmation: "password123",
    roles: [ "user" ]
  )
end
