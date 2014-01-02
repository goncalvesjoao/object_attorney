module PostForm
  
  class Base

    include ObjectAttorney

    represents :post

    delegate_properties :title, :body, to: :post

    has_many :comments

    validates_presence_of :title

  end


  class Explicit

    include ObjectAttorney

    represents :post

    has_many :comments

    validates_presence_of :title

    def body=(value)
      post.body = value
    end

    def body
      post.body
    end

    def title=(value)
      post.title = value
    end

    def title
      post.title
    end

    def build_comment(attributes = {})
      post.comments.build(attributes)
    end

    def existing_comments
      post.comments
    end

  end
  
end