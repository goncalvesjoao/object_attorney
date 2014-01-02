module FormObjects
  
  module BulkPostsWithFormObjects
    
    class Base

      include ObjectAttorney

      has_many :posts, class_name: FormObjects::Post::Base

    end
    
    class Explicit

      include ObjectAttorney

      has_many :posts
      
      def build_post(attributes = {})
        FormObjects::Post::Base.new(attributes)
      end

      def existing_posts
        FormObjects::Post::Base.all
      end

    end

  end

end