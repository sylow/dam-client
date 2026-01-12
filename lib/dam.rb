# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'
require 'hashie'
require 'parallel'

# Core modules
require_relative 'dam/errors'
require_relative 'dam/base_client'
require_relative 'dam/factory'

# Models (order matters - dependencies first)
require_relative 'dam/models/base_model'
require_relative 'dam/models/folder'
require_relative 'dam/models/thumbnail'
require_relative 'dam/models/xmp_metadata'
require_relative 'dam/models/access_token'
require_relative 'dam/models/asset'
require_relative 'dam/models/search_result'

# Provider implementations (modules before clients)
# Webdam
require_relative 'webdam/search_methods'
require_relative 'webdam/authorization_methods'
require_relative 'webdam/asset_methods'
require_relative 'webdam/models/asset'
require_relative 'webdam/models/xmp_metadata'
require_relative 'webdam/client'

# Bynder
require_relative 'bynder/search_methods'
require_relative 'bynder/authorization_methods'
require_relative 'bynder/asset_methods'
require_relative 'bynder/models/folder'
require_relative 'bynder/models/thumbnail'
require_relative 'bynder/models/asset'
require_relative 'bynder/models/search_result'
require_relative 'bynder/client'

module Dam
  VERSION = '0.1.0'
end
