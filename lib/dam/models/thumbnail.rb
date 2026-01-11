module Dam
  module Models

    class Thumbnail < BaseModel
      coerce_key :size, Integer

      def size
        self['size']
      end
    end

  end
end
