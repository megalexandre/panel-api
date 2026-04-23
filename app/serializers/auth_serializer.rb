class AuthSerializer
  def initialize(tokens)
    @tokens = tokens
  end

  def login_response
    @tokens.slice(:token, :refresh_token, :expires_at)
  end
end
