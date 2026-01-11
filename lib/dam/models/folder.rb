module Dam
  module Models

    class Folder < BaseModel
      coerce_key :type, Symbol
    end

  end
end
