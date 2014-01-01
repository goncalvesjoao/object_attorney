module FormObjects

  module BulkPosts
  
    class Base

      include ObjectAttorney

      accepts_nested_objects :posts

    end

    class Explicit

      include ObjectAttorney

      accepts_nested_objects :posts
      
      def build_post(attributes = {})
        ::Post.new(attributes)
      end

      def existing_posts
        ::Post.all
      end

    end

  end

end