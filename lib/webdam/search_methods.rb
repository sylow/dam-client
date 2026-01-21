module Webdam
  module SearchMethods

    def search(options)
      r = get('search', options)
      Models::SearchResult.new(r)
    end

    def url(asset_id)
      get("assets/#{asset_id}")
    end
    
    def search_for_item_assets(item_no)
      # Search for all asset types (images, documents, videos)
      # WebDam supports comma-separated types
      search(
        searchfield: 'customfield1',
        query: item_no.to_s,
        types: 'image,document,video'
      )
    end

  end
end
