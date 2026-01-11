module Dam
  class Factory
    class << self
      # Returns the appropriate DAM client based on ASSET_SERVICE environment variable
      # Defaults to Webdam for backwards compatibility
      #
      # Usage:
      #   client = Dam::Factory.client
      #   results = client.search(query: "product")
      #
      def client
        case ENV.fetch('ASSET_SERVICE', 'webdam').downcase
        when 'webdam'
          Webdam::Client.new
        when 'bynder'
          Bynder::Client.new
        else
          raise Dam::ConfigurationError, "Unknown ASSET_SERVICE: #{ENV['ASSET_SERVICE']}. Valid options: webdam, bynder"
        end
      end

      # Alias for convenience
      def new
        client
      end
    end
  end
end
