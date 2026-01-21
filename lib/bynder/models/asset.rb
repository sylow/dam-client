module Bynder
  module Models

    class Asset < Dam::Models::Asset
      # Bynder-specific coercions
      # Note: Bynder doesn't return folder in search results, but we keep for compatibility
      coerce_key :folder, Bynder::Models::Folder
      # Don't coerce thumbnailurls - we override the method to build from 'thumbnails' field

      # Bynder-specific implementation for downloading PDFs
      def pdf_download_url
        # Bynder provides download URLs in derivatives or original
        # https://developer-docs.bynder.com/api/v4/media/{id}/download/

        # Try original URL first
        original_url = self.dig('files', 'original', 'url') ||
                       self.dig('original', 'url') ||
                       self['originalUrl']

        return original_url if original_url

        # Try derivatives
        if self['derivatives']
          pdf_derivative = self['derivatives'].find {|k, v| k =~ /pdf/i }
          return pdf_derivative&.last&.dig('url') if pdf_derivative
        end

        # Fallback to thumbnail URL with download param
        thumbnailurls&.first&.url || self['url']
      end

      def provider_name
        'bynder'
      end

      # Generic download/media URL for all asset types
      def media_url
        # For Bynder, construct the download URL using the asset ID
        # Format: https://{bynder-domain}/api/v4/media/{id}/download/
        # Note: bynder_api_url already includes /api, so we only append /v4/media/...
        bynder_url = ENV['bynder_api_url']
        return nil unless bynder_url && self['id']

        # Remove trailing slash from base URL if present
        base_url = bynder_url.sub(/\/$/, '')
        "#{base_url}/v4/media/#{self['id']}/download/"
      end

      # Alias for consistency with WebDam
      def download_url
        media_url
      end

      # Provide a folder stub since Bynder doesn't return folder in search results
      # but the code expects asset.folder.name
      def folder
        # Check if we have brandId or collection info
        if self['brandId']
          # Return a minimal folder object
          # In Bynder, check if High Resolution might be indicated by image dimensions
          # or other properties
          folder_name = determine_folder_name
          Bynder::Models::Folder.new(name: folder_name, type: :folder)
        else
          # Return minimal folder
          Bynder::Models::Folder.new(name: 'Default', type: :folder)
        end
      end

      # Override to handle Bynder's different response structure
      def filetype
        # Bynder uses 'extension' as an array, Webdam uses string
        ext = self['extension']
        if ext.is_a?(Array)
          ext.first
        else
          ext || self['type'] || super
        end
      end

      # Override to handle Bynder's status field
      def status
        # Bynder uses archive field (0 = active, 1 = archived)
        # isArchived is also used in some responses
        return 'archived' if self['archive'] == 1 || self['isArchived']
        return 'active'
      end

      # Override to handle Bynder's thumbnail structure
      def thumbnailurls
        # Bynder structure: thumbnails: { mini: "url", webimage: "url", thul: "url"}
        # Sometimes thumbnails have full data: { mini: {url, width, height}, ...}
        thumbs = self['thumbnails']
        return [] unless thumbs

        # Map of Bynder thumbnail sizes to approximate pixel sizes
        size_map = {
          'mini' => 150,
          'thul' => 220,
          'webimage' => 550,
          'transformBaseUrl' => 1280
        }

        # Convert Bynder thumbnail hash to array of Thumbnail objects
        thumbs.map do |size_name, thumb_data|
          if thumb_data.is_a?(Hash) && thumb_data['url']
            # Full thumbnail object with metadata
            Bynder::Models::Thumbnail.new(
              url: thumb_data['url'],
              size: thumb_data['width'] || thumb_data['height'] || size_map[size_name] || 0
            )
          elsif thumb_data.is_a?(String)
            # Just a URL string
            Bynder::Models::Thumbnail.new(
              url: thumb_data,
              size: size_map[size_name] || 0
            )
          end
        end.compact
      end

      private

      def determine_folder_name
        # Try to determine if this is high or low resolution based on file properties
        # Bynder doesn't have explicit folders like Webdam, so we infer from dimensions
        width = self['width'].to_i
        height = self['height'].to_i

        # Consider it high resolution if either dimension is >= 2000px
        if width >= 2000 || height >= 2000
          'High Resolution'
        elsif width > 0 || height > 0
          'Low Resolution'
        else
          'Default'
        end
      end

      protected

      # Bynder-specific XMP metadata fetching
      def fetch_xmp_metadata_from_provider
        Bynder::Client.new.asset_xmp_metadata(id)
      end
    end

  end
end
