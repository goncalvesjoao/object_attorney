module FormObjects
    
  module BulkPostsAllowOnlyExisting

    class Base < BulkPosts::Base

      def build_post(attributes = {}, post = nil)
        nil
      end

    end

    class Explicit < BulkPosts::Base

      def build_post(attributes = {}, post = nil)
        nil
      end

    end

  end

end