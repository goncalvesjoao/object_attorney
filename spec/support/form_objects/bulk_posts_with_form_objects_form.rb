module BulkPostsWithFormObjectsForm
  
  class Base

    include ObjectAttorney

    has_many :posts, class_name: PostForm::Base

  end
  
  class Explicit

    include ObjectAttorney

    has_many :posts
    
    def build_post(attributes = {})
      PostForm::Base.new(attributes)
    end

    def existing_posts
      PostForm::Base.all
    end

  end

end
