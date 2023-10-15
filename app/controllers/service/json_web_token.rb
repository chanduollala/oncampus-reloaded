module Service
  class JsonWebToken
    def self.secret_key
      ENV["SECRET_KEY_BASE"]
#Rails.application.secrets.secret_key_base.to_s
    end

    def self.encode(payload, exp = 24.hours.from_now)
      payload[:exp] = exp.to_i
#      print(secret_key)
      JWT.encode(payload, secret_key)
    end

    def self.decode(token)
      decoded = JWT.decode(token, secret_key, true)[0]
      HashWithIndifferentAccess.new(decoded)
    end
  end
end
