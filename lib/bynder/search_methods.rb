module Bynder
  module SearchMethods

    def search(options)
      # Map common search options to Bynder API parameters
      params = map_search_params(options)

      # Bynder API v4 media endpoint
      # Documentation: https://bynder-api-documentation.readme.io/reference/get_api-v4-media
      # Uses GET /api/v4/media/ with query parameters for filtering
      r = get('/api/v4/media/', params)

      # Transform Bynder response to common format
      transformed = transform_search_response(r)
      Models::SearchResult.new(transformed)
    end

    def url(asset_id)
      # Get specific asset details
      # https://developer-docs.bynder.com/api/v4/media/{id}
      get("/api/v4/media/#{asset_id}/")
    end

    def search_for_item_assets(item_no)
      # Bynder metaproperty filtering is complex because it requires option IDs
      # Strategy: Use keyword search to narrow results, then filter by property_Item_Number
      # This combines efficiency of server-side search with accuracy of client-side filtering

      # Search for all asset types (images, documents, videos)
      # Note: Bynder's type parameter doesn't support multiple values in one request
      # So we need to make separate searches and combine results
      all_items = []

      ['image', 'document', 'video'].each do |asset_type|
        result = search(
          keyword: item_no.to_s,
          type: asset_type,
          limit: 1000  # Bynder's max limit per request
        )
        all_items.concat(result.items)
      end

      # Filter to only include assets where item_no is actually in property_Item_Number
      # This prevents false positives from keyword matching other fields
      filtered_items = all_items.select do |asset|
        item_numbers = asset['property_Item_Number'] || []
        item_numbers = [item_numbers] unless item_numbers.is_a?(Array)
        item_numbers.map(&:to_s).include?(item_no.to_s)
      end

      # Return a new search result with filtered items
      Models::SearchResult.new(
        items: filtered_items,
        total: filtered_items.size
      )
    end

    def search_for_featured_products(limit_pages: nil)
      # Fetch all assets marked with Product_Featured in property_Asset_Sub-Type
      # Since Bynder's propertyOptionId filter may not work reliably for metaproperty values,
      # we use a keyword search and then filter client-side for accuracy
      #
      # Parameters:
      #   limit_pages: Optional max number of pages to fetch. Useful for testing or when dealing
      #                with very large result sets. If nil, fetches all pages.

      all_items = []
      page = 1
      pages_fetched = 0

      loop do
        result = search(
          keyword: 'Product_Featured',
          type: 'image',
          limit: 1000,  # Bynder's max limit per request
          page: page
        )

        break if result.items.empty?
        all_items.concat(result.items)
        pages_fetched += 1

        # Check pagination limit if specified
        break if limit_pages && pages_fetched >= limit_pages

        # If we got fewer items than the limit, we've reached the end
        break if result.items.size < 1000

        page += 1
      end

      # Filter to only include assets where property_Asset_Sub-Type contains 'Product_Featured'
      filtered_items = all_items.select do |asset|
        sub_types = asset['property_Asset_Sub-Type'] || []
        sub_types = [sub_types] unless sub_types.is_a?(Array)
        sub_types.map(&:to_s).include?('Product_Featured')
      end

      # Return search result with all featured product images
      Models::SearchResult.new(
        items: filtered_items,
        total: filtered_items.size
      )
    end

    private

    def map_search_params(options)
      # Map Webdam-style params to Bynder API params
      # Bynder API v4 media endpoint supports these parameters:
      # - keyword: text search across asset fields
      # - type: filter by asset type (image, video, document, etc.)
      # - limit: results per page (default 50, max 1000)
      # - page: page number for pagination
      # - propertyOptionId: filter by metaproperty values
      # - brandId: filter by brand
      # - collectionId: filter by collection
      # - isPublic: filter public assets (0 or 1)
      # - dateCreated: filter by creation date
      # - dateModified: filter by modification date

      params = {}

      # Map query to keyword for text search
      params[:keyword] = options[:query] if options[:query]
      params[:keyword] = options[:keyword] if options[:keyword]

      # Map types (Bynder uses 'type' parameter, can be single value or array)
      # Support both :type (singular) and :types (plural) for flexibility
      params[:type] = options[:type] || options[:types] if options[:type] || options[:types]

      # Pagination parameters
      params[:limit] = options[:limit] if options[:limit]
      params[:page] = options[:page] if options[:page]

      # Additional filters (pass through if provided)
      params[:propertyOptionId] = options[:propertyOptionId] if options[:propertyOptionId]
      params[:brandId] = options[:brandId] if options[:brandId]
      params[:collectionId] = options[:collectionId] if options[:collectionId]
      params[:isPublic] = options[:isPublic] if options[:isPublic]

      params.compact
    end

    def transform_search_response(response)
      # Bynder returns different structure - normalize to match Webdam format
      # Bynder response: { "data": [...], "count": {...}, "total": n }

      if response.is_a?(Array)
        items = response
        total = response.size
      else
        items = response['data'] || response['media'] || []
        total = response['total'] || items.size
      end

      {
        items: items,
        total: total
      }
    end

  end
end
