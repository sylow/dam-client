module Dam
  module Models

    class XmpMetadata < BaseModel
      def imagetype
        self[:imagetype]
      end
    end

  end
end
