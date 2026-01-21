module Bynder
  module AssetMethods

    def asset_xmp_metadata(asset_id)
      # Bynder stores metadata differently from Webdam
      # Fetch asset details which contain metaproperties
      asset_data = get("/api/v4/media/#{asset_id}/")

      # Transform Bynder metaproperties to XMP format expected by app
      xmp_data = transform_bynder_metadata(asset_data)
      Dam::Models::XmpMetadata.new(xmp_data)
    end

    # Get the S3 download URL for a Bynder asset
    # According to https://bynder-api-documentation.readme.io/reference/get_api-v4-media-id-download
    def asset_download_url(asset_id)
      # Fetch the download endpoint which returns JSON with s3_file
      download_data = get("/v4/media/#{asset_id}/download/")
      download_data['s3_file']
    end

    private

    def transform_bynder_metadata(asset_data)
      # Map Bynder's metaproperties structure to expected XMP fields
      # Bynder metaproperties are typically in asset_data['property_{option_id}']
      # or asset_data['metaproperties']

      metaproperties = asset_data['metaproperties'] || {}

      # TODO: Configure these mappings based on your Bynder metaproperty setup
      # Example mappings (you'll need to adjust these based on your Bynder configuration):
      {
        imagetype: extract_image_type(metaproperties, asset_data),
        # Add more XMP field mappings as needed
        # e.g., photographer, copyright, etc.
      }
    end

    def extract_image_type(metaproperties, asset_data)
      # Try to find image type from Bynder metaproperties
      # This is highly dependent on your Bynder configuration

      # Option 1: Check property_Asset_Type (Bynder metaproperty)
      asset_types = asset_data['property_Asset_Type'] || []
      asset_types = [asset_types] unless asset_types.is_a?(Array)

      # Recognize Product_Renders and Product_Photography as product photos
      if asset_types.any? {|t| t =~ /Product_Renders|Product_Photography/i }
        return 'In Studio Product Photography'
      end

      # Option 2: Check tags
      tags = asset_data['tags'] || []

      # Check for product photography patterns
      if tags.any? {|tag| tag =~ /product.*photography/i }
        return 'In Studio Product Photography'
      end

      # Bynder uses "Curated Images" tag for product photos
      if tags.any? {|tag| tag =~ /curated.*images/i }
        return 'In Studio Product Photography'
      end

      # Option 3: Check metaproperties
      # Example: metaproperties['image_type'] or similar
      image_type_field = metaproperties['image_type'] ||
                         metaproperties['ImageType'] ||
                         metaproperties['type']

      return image_type_field if image_type_field

      # Option 4: Check asset type
      asset_type = asset_data['type'] || ''
      return asset_type if asset_type.present?

      # Default
      ''
    end

  end
end
