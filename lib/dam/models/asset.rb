module Dam
  module Models

    class Asset < BaseModel
      coerce_key :type, Symbol
      coerce_key :folder, Folder
      coerce_key :thumbnailurls, Array[Thumbnail]

      # Common interface method - subclasses should call their specific client
      def xmp_metadata
        self['xmp_metadata'] ||= fetch_xmp_metadata_from_provider
      end

      # Provider-specific implementations must override this
      def pdf_download_url
        raise NotImplementedError, "Subclass must implement pdf_download_url"
      end

      # Generic media/download URL - providers should override
      def media_url
        self['mediaUrl'] || self['url']
      end

      # Alias for consistency
      def download_url
        media_url
      end

      # Provider-specific implementations must override this
      def provider_name
        'unknown'
      end

      protected

      # Subclasses should override this to call their provider's client
      def fetch_xmp_metadata_from_provider
        raise NotImplementedError, "Subclass must implement fetch_xmp_metadata_from_provider"
      end
    end

  end
end
