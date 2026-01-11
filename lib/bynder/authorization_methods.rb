module Bynder
  module AuthorizationMethods

    def access_token
      cached = Rails.cache.read("bynder/access_token")
      return cached if cached

      # Bynder uses OAuth2 client credentials flow for server-to-server
      # https://developer-docs.bynder.com/authentication-oauth2-oauth-apps
      response = connection.post('/v6/authentication/oauth2/token') do |req|
        req.body = {
          grant_type: 'client_credentials',
          client_id: ENV['bynder_client_id'],
          client_secret: ENV['bynder_client_secret']
        }
      end

      unless response.success?
        raise Dam::AuthenticationError, "Bynder authentication failed: #{response.body}"
      end

      response_data = Dam::Models::AccessToken.new(response.body)
      # Bynder tokens typically expire in 1 hour (3600 seconds)
      Rails.cache.write(
        "bynder/access_token",
        response_data.access_token,
        expires_in: (response_data.expires_in - 60).seconds,
        raw: true
      )
      response_data.access_token
    end

  end
end
