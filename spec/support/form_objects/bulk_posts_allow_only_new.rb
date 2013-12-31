module FormObjects
  
  module BulkPostsAllowOnlyNew
    
    class Base < BulkPosts::Base

      def existing_posts
        []
      end

    end

    class Explicit < BulkPosts::Base

      def existing_posts
        []
      end

    end

  end

end