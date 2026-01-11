module Webdam
  module AssetMethods

    def asset_xmp_metadata(asset_id)
      Models::XmpMetadata.new(get("assets/#{asset_id}/metadatas/xmp"))
    end

  end
end
