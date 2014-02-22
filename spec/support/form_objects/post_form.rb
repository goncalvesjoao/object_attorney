module PostForm
  
  class Base

    include ObjectAttorney

    represents :post, properties: [:title, :body]

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
  

  class Presenter
    include ObjectAttorney
    represents :post, delegate_missing_methods: true, properties: [:title]
  end


  class Properties1
    include ObjectAttorney
    represents :post
    properties :title, :user_id
  end

  class Properties2
    include ObjectAttorney
    represents :post, properties: [:title, :user_id]
  end


  class Getters1
    include ObjectAttorney
    represents :post
    getters :title, :user_id
  end

  class Getters2
    include ObjectAttorney
    represents :post, getters: [:title, :user_id]
  end


  class Setters1
    include ObjectAttorney
    represents :post
    setters :title, :user_id
  end

  class Setters2
    include ObjectAttorney
    represents :post, setters: [:title, :user_id]
  end


  class GrandFather
    include ObjectAttorney
    represents :post
  end

  class Father < GrandFather
    properties :title

    add_attribute_key :email, :author

    attr_accessor :email, :author
  end

  class Son < Father
    getters :body
  end

  class GrandSon < Son
    setters :user_id

    add_attribute_key :date

    attr_accessor :date
  end

end
