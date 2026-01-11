require_relative '../dam/errors'

module Webdam

  class Client < Dam::BaseClient
    attr_reader :connection

    def initialize
      @connection = Faraday.new(url: 'https://apiv2.webdamdb.com/') do |conn|
        conn.request :url_encoded
        conn.response :json
        conn.adapter :net_http
      end
    end

    def method_missing(method, *args)
      r = connection.send method, *args do |req|
        req.headers['Authorization'] = "Bearer #{access_token}" unless args[0] == 'oauth2/token'
      end

      unless r.success?
        raise Dam::Error, r.body['message'] || "#{r.body['error']}, #{r.body['error_description']}"
      end

      r.body
    end

    include AuthorizationMethods
    include SearchMethods
    include AssetMethods

  end

end
