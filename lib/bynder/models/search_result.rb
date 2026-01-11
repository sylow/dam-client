module Bynder
  module Models

    class SearchResult < Dam::Models::SearchResult
      # Coerce items to Bynder-specific Asset class
      coerce_key :items, Array[Asset]
    end

  end
end
