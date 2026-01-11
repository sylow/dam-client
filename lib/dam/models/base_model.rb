module Dam
  module Models

    class BaseModel < Hash
      include Hashie::Extensions::MethodAccessWithOverride
      include Hashie::Extensions::Coercion
      include Hashie::Extensions::IndifferentAccess
      include Hashie::Extensions::MergeInitializer
    end

  end
end
