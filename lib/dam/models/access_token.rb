module Dam
  module Models

    class AccessToken < BaseModel
      def expires_at
        (expires_in - 5).seconds.from_now
      end
    end

  end
end
