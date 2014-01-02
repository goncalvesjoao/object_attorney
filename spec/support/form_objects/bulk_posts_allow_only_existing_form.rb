module BulkPostsAllowOnlyExistingForm

  class Base < BulkPostsForm::Base

    def build_post(attributes = {})
      nil
    end

  end

  class Explicit < BulkPostsForm::Base

    def build_post(attributes = {})
      nil
    end

  end

end
