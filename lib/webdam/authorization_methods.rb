module Webdam
  module AuthorizationMethods

    def access_token
      cached = Rails.cache.read("webdam/access_token")
      return cached if cached

      response = post('oauth2/token',
        grant_type:    'password',
        client_id:     ENV['webdam_client_id'],
        client_secret: ENV['webdam_client_secret'],
        username:      ENV['webdam_username'],
        password:      ENV['webdam_password'],
      )

      response = Dam::Models::AccessToken.new(response)
      Rails.cache.write("webdam/access_token", response.access_token, expires_in: (response.expires_in - 60).seconds, raw: true)
      response.access_token
    end

  end
end
