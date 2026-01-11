module Dam
  module Models

    class SearchResult < BaseModel
      # Note: Subclasses should coerce items to their specific Asset type
      # e.g., coerce_key :items, Array[Webdam::Models::Asset]
      coerce_key :items, Array[Asset]

      def fetch_xmp_metadata
        Parallel.each(items, in_threads: 30) do |asset|
          asset.xmp_metadata
        end
      end

      def images
        filter_items {|asset|
          %w(tif png jpg jpeg gif).include?(asset.filetype.downcase)
        }
      end

      def pdfs
        filter_items {|asset|
          %w(pdf).include?(asset.filetype.downcase)
        }
      end

      def active
        with_status('active')
      end

      def with_status(status)
        filter_items {|asset|
          asset.status == status
        }
      end

      def product_photos
        fetch_xmp_metadata
        filter_items {|asset|
          asset.xmp_metadata.imagetype =~ /In Studio Product Photography/i
        }
      end

      private

      def filter_items(&block)
        self.class.new(items: items.select(&block))
      end
    end

  end
end
