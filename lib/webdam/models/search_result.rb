module Webdam
  module Models

    class SearchResult < Dam::Models::SearchResult
      # Coerce items to Webdam-specific Asset class
      coerce_key :items, Array[Asset]
    end

  end
end
