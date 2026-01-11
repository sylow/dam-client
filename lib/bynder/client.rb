require_relative '../dam/errors'

module Bynder

  class Client < Dam::BaseClient
    attr_reader :connection

    def initialize
      # Bynder portal URL format: https://{your-bynder-domain}.bynder.com/
      bynder_url = ENV['bynder_api_url']
      raise Dam::ConfigurationError, "bynder_api_url not configured" unless bynder_url

      @connection = Faraday.new(url: bynder_url) do |conn|
        conn.request :url_encoded
        conn.response :json
        conn.adapter :net_http
      end
    end

    def method_missing(method, *args)
      r = connection.send method, *args do |req|
        req.headers['Authorization'] = "Bearer #{access_token}"
      end

      unless r.success?
        handle_error(r)
      end

      r.body
    end

    include AuthorizationMethods
    include SearchMethods
    include AssetMethods

    private

    def handle_error(response)
      case response.status
      when 401
        raise Dam::AuthenticationError, "Bynder authentication failed: #{response.body['message']}"
      when 404
        raise Dam::NotFoundError, "Asset not found: #{response.body['message']}"
      when 429
        raise Dam::RateLimitError, "Bynder rate limit exceeded"
      else
        raise Dam::Error, response.body['message'] || "Bynder API error: #{response.status}"
      end
    end
  end

end
