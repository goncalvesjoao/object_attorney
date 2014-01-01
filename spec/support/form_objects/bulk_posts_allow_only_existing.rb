module FormObjects
    
  module BulkPostsAllowOnlyExisting

    class Base < BulkPosts::Base

      def build_post(attributes = {})
        nil
      end

    end

    class Explicit < BulkPosts::Base

      def build_post(attributes = {})
        nil
      end

    end

  end

end