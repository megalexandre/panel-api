class JwtService
  SECRET_KEY = Rails.application.credentials.dig(:jwt_secret) || 'your-secret-key-change-in-production'
  ACCESS_EXPIRATION  = ENV.fetch('JWT_ACCESS_EXP_HOURS',  '1').to_i.hours
  REFRESH_EXPIRATION = ENV.fetch('JWT_REFRESH_EXP_DAYS', '1').to_i.days

  class << self
    def encode(payload, exp = ACCESS_EXPIRATION.from_now)
      payload = payload.dup
      payload['exp'] = exp.to_i
      payload['iat'] = Time.current.to_i

      JWT.encode(payload, SECRET_KEY, 'HS256')
    end

    def decode(token)
      decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })
      decoded[0].with_indifferent_access
    rescue JWT::DecodeError, JWT::ExpiredSignature => e
      { error: e.message }.with_indifferent_access
    end

    def encode_refresh(payload)
      encode(payload.merge('token_type' => 'refresh'), REFRESH_EXPIRATION.from_now)
    end

    def decode_refresh(token)
      payload = decode(token)
      return payload if payload[:error].present?
      return { error: 'Invalid token type' }.with_indifferent_access if payload[:token_type] != 'refresh'

      payload
    end

    def valid?(token)
      decoded = decode(token)
      decoded[:error].nil?
    end
  end
end
