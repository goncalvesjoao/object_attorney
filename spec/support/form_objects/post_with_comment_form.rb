module FormObjects
  
  module PostWithCommentForm

    class Base < Post::Base

      def build_comment(attributes = {}, comment = nil)
        FormObjects::Comment.new(attributes, comment || post.comments.new)
      end

      def existing_comments
        post.comments.map { |comment| build_comment({}, comment) }
      end

    end
    
    class Explicit < Post::Base

      def build_comment(attributes = {}, comment = nil)
        FormObjects::Comment.new(attributes, comment || post.comments.new)
      end

      def existing_comments
        post.comments.map { |comment| build_comment({}, comment) }
      end

    end
    
  end

end