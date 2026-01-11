module Dam
  # Base client defining the interface all DAM providers must implement
  # This uses Ruby duck typing - no need to inherit from this class,
  # but all provider clients should implement these methods.
  #
  # Required Methods:
  # - search(options) -> Dam::Models::SearchResult or subclass
  # - url(asset_id) -> Hash with asset details
  # - search_for_item_assets(item_no) -> Dam::Models::SearchResult or subclass
  # - asset_xmp_metadata(asset_id) -> Dam::Models::XmpMetadata
  # - access_token -> String
  #
  # Example usage:
  #   client = Dam::Factory.client
  #   results = client.search(query: "product")
  #   asset = client.url("12345")
  #
  class BaseClient
    # Hook for subclasses to initialize HTTP connection
    def initialize
      raise NotImplementedError, "Subclasses must implement initialize"
    end

    # Search interface - returns standardized SearchResult or subclass
    def search(options)
      raise NotImplementedError, "Subclasses must implement search"
    end

    # Asset URL retrieval - returns hash with asset details
    def url(asset_id)
      raise NotImplementedError, "Subclasses must implement url"
    end

    # Item-specific asset search - returns SearchResult
    def search_for_item_assets(item_no)
      raise NotImplementedError, "Subclasses must implement search_for_item_assets"
    end

    # Asset metadata retrieval - returns XmpMetadata
    def asset_xmp_metadata(asset_id)
      raise NotImplementedError, "Subclasses must implement asset_xmp_metadata"
    end

    # Authentication token
    def access_token
      raise NotImplementedError, "Subclasses must implement access_token"
    end
  end
end
