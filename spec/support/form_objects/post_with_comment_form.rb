module PostWithCommentForm

  class Base < PostForm::Base

    has_many :comments, class_name: CommentForm

  end
  
  class Explicit < PostForm::Base

    def build_comment(attributes = {})
      CommentForm.new(attributes)
    end

    def existing_comments
      post.comments.map { |comment| CommentForm.new({}, comment) }
    end

  end
  
end
