module Bynder
  module Models

    class Folder < Dam::Models::Folder
      # Bynder uses 'collections' instead of folders
      # This provides compatibility mapping

      def name
        # Bynder collections have 'name' field
        self['name'] || self['collectionName'] || super
      end
    end

  end
end
