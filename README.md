# DAM Client

A unified Ruby client for Digital Asset Management (DAM) systems. Switch between Webdam and Bynder seamlessly using the same interface.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dam-client', path: '../dam-client'  # For local development
# Or from a git repository:
# gem 'dam-client', git: 'https://github.com/razorusa/dam-client'
```

And then execute:

```bash
$ bundle install
```

## Configuration

Configure your DAM provider using environment variables:

```bash
# Choose your provider (webdam or bynder)
export ASSET_SERVICE=bynder

# Bynder credentials
export bynder_api_url=https://your-portal.bynder.com/api
export bynder_client_id=your-client-id
export bynder_client_secret=your-client-secret

# OR Webdam credentials
export webdam_api_url=https://apiv2.webdamdb.com
export webdam_client_id=your-client-id
export webdam_client_secret=your-client-secret
```

## Usage

### Basic Search

```ruby
# Get a client instance (automatically uses configured provider)
client = Dam::Factory.client

# Search for assets
results = client.search(query: "product", limit: 50)

results.items.each do |asset|
  puts "#{asset.name} - #{asset.id}"

  # Access thumbnails
  asset.thumbnailurls.each do |thumb|
    puts "  #{thumb.size}px: #{thumb.url}"
  end
end
```

### Search by Item Number

```ruby
# Search for assets by specific item number
results = client.search_for_item_assets("12345678")

# Get product photos only
photos = results.product_photos

# Get the best image
best_photo = photos.items.first
puts best_photo.image_url
```

### Get Asset Details

```ruby
# Get a specific asset
asset = client.url("asset-id-here")

# Access metadata
metadata = client.asset_xmp_metadata("asset-id-here")
puts metadata.imagetype
```

## Supported Providers

### Webdam
- Full search functionality
- Folder-based organization
- XMP metadata support

### Bynder
- Advanced metaproperty filtering
- Tag-based organization
- Priority-based image selection (Product_Main)
- Automatic image type recognition

## Provider-Specific Features

### Bynder

The Bynder client includes special handling for:

- **Asset Sub-Type Priority**: Assets with `Asset Sub-Type = Product_Main` are automatically prioritized
- **Product Photo Detection**: Recognizes `Product_Renders` and `Product_Photography` asset types
- **Item Number Filtering**: Filters search results by `property_Item_Number` metaproperty

### Webdam

The Webdam client provides:

- **Folder Navigation**: Access to hierarchical folder structure
- **XMP Metadata**: Full XMP metadata extraction
- **Legacy Support**: Backwards compatibility with existing Webdam integrations

## Models

All providers return standardized models:

- `Dam::Models::Asset` - Base asset with common fields
- `Dam::Models::SearchResult` - Search results with pagination
- `Dam::Models::Thumbnail` - Thumbnail URLs and sizes
- `Dam::Models::XmpMetadata` - Extracted XMP metadata
- `Dam::Models::Folder` - Folder/collection information

## Switching Providers

Simply change the `ASSET_SERVICE` environment variable:

```bash
# Switch to Bynder
export ASSET_SERVICE=bynder

# Switch to Webdam
export ASSET_SERVICE=webdam
```

No code changes required!

## Development

After checking out the repo, run `bundle install` to install dependencies.

Run tests with:

```bash
$ bundle exec rspec
```

## Contributing

Bug reports and pull requests are welcome.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
