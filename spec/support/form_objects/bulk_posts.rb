module FormObjects

  module BulkPosts
  
    class Base

      include ObjectAttorney

      has_many :posts

    end

    class Explicit

      include ObjectAttorney

      has_many :posts
      
      def build_post(attributes = {})
        ::Post.new(attributes)
      end

      def existing_posts
        ::Post.all
      end

    end

  end

end