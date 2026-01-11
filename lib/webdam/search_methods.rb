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
      search(
        searchfield: 'customfield1',
        query: item_no.to_s,
        types: 'image'
      )
    end

  end
end
