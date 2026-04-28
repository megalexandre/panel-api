module ApiHelpers
  def json_response
    JSON.parse(last_response.body)
  end

  def auth_headers_for(user)
    token = JwtService.encode(
      user_id: user.id,
      email: user.email,
      roles: user.roles
    )
    { "HTTP_AUTHORIZATION" => "Bearer #{token}", "CONTENT_TYPE" => "application/json" }
  end

  def json_headers
    { "CONTENT_TYPE" => "application/json" }
  end
end

World(ApiHelpers)
