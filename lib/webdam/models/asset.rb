module Webdam
  module Models

    class Asset < Dam::Models::Asset
      # Webdam-specific coercions
      coerce_key :folder, Dam::Models::Folder
      coerce_key :thumbnailurls, Array[Dam::Models::Thumbnail]

      # Webdam-specific implementation for downloading PDFs
      def pdf_download_url
        details = Webdam::Client.new.url(self.id)
        details["mediaUrl"].scan(/PDFFile\s:\s"(.+?)"/).flatten.first&.concat("?dl=1") || details["hiResURLRaw"]
      end

      def provider_name
        'webdam'
      end

      # Generic download/media URL for all asset types
      # WebDam includes mediaUrl in the asset data
      def media_url
        self['mediaUrl']
      end

      # Alias for consistency
      def download_url
        media_url
      end

      protected

      # Webdam-specific XMP metadata fetching
      def fetch_xmp_metadata_from_provider
        Webdam::Client.new.asset_xmp_metadata(id)
      end
    end

  end
end
