# frozen_string_literal: true
class AuthService
  attr_reader :email, :password, :errors

  def initialize(email:, password:)
    @email = email
    @password = password
    @errors = []
  end

  def authenticate
    validate_params
    return false if errors.any?

    user = User.find_by(email: email)

    unless user&.authenticate(password)
      @errors << 'Invalid email or password'
      return false
    end

    user
  end

  def self.issue_tokens(user)
    payload    = { user_id: user.id, email: user.email, roles: user.roles }
    expires_at = JwtService::ACCESS_EXPIRATION.from_now
    {
      token:         JwtService.encode(payload, expires_at),
      refresh_token: JwtService.encode_refresh(payload),
      expires_at:    expires_at.iso8601
    }
  end

  def self.refresh(raw_token)
    payload = JwtService.decode_refresh(raw_token)
    return { error: payload['error'] } if payload['error']

    user = User.find_by(id: payload['user_id'])
    return { error: 'User not found' } unless user

    issue_tokens(user)
  end

  private

  def validate_params
    @errors << 'Email is required' if email.blank?
    @errors << 'Password is required' if password.blank?
  end
end
