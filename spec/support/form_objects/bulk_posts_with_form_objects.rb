module FormObjects
  
  module BulkPostsWithFormObjects
    
    class Base

      include ObjectAttorney

      accepts_nested_objects :posts, class_name: FormObjects::Post::Base

    end
    
    class Explicit

      include ObjectAttorney

      accepts_nested_objects :posts
      
      def build_post(attributes = {})
        FormObjects::Post::Base.new(attributes)
      end

      def existing_posts
        FormObjects::Post::Base.all
      end

    end

  end

end