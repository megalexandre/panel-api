Given("I am authenticated as a user") do
  @current_user = User.create!(
    email: "cucumber-user@example.com",
    password: "password123",
    password_confirmation: "password123",
    roles: [ "user" ]
  )
  @headers = auth_headers_for(@current_user)
end
