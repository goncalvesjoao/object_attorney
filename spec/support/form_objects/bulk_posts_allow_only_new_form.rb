module BulkPostsAllowOnlyNewForm
  
  class Base < BulkPostsForm::Base

    def existing_posts
      []
    end

  end

  class Explicit < BulkPostsForm::Base

    def existing_posts
      []
    end

  end

end
