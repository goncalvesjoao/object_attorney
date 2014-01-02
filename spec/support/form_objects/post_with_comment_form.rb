module FormObjects
  
  module PostWithCommentForm

    class Base < Post::Base

      has_many :comments, class_name: FormObjects::Comment

    end
    
    class Explicit < Post::Base

      def build_comment(attributes = {})
        FormObjects::Comment.new(attributes)
      end

      def existing_comments
        post.comments.map { |comment| FormObjects::Comment.new({}, comment) }
      end

    end
    
  end

end