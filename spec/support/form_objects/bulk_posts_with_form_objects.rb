module FormObjects
  
  module BulkPostsWithFormObjects
    
    class Base

      include ObjectAttorney

      accepts_nested_objects :posts
      
      def build_post(attributes = {}, post = nil)
        FormObjects::Post::Base.new(attributes, post || ::Post.new)
      end

      def existing_posts
        ::Post.all.map { |post| build_post({}, post) }
      end

    end
    
    class Explicit

      include ObjectAttorney

      accepts_nested_objects :posts
      
      def build_post(attributes = {}, post = nil)
        FormObjects::Post::Base.new(attributes, post || ::Post.new)
      end

      def existing_posts
        ::Post.all.map { |post| build_post({}, post) }
      end

    end

  end

end