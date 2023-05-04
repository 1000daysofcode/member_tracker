# frozen_string_literal: true

class AuthenticationTokenService
  HMAC_SECRET = 'my$ecretK3y'
  ALGO_TYPE = 'HS256'
  def self.encode(user_id)
    payload = { user_id: }

    JWT.encode payload, HMAC_SECRET, ALGO_TYPE
  end

  def self.decode(token)
    decoded_token = JWT.decode token, HMAC_SECRET, true, { algorithm: ALGO_TYPE }
    decoded_token.first['user_id']
  end
end
