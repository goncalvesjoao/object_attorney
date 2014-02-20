require "spec_helper"

describe PostWithCommentValidationsForm do

  it "1. 'PostWithCommentValidationsForm' becomes invalid if 'Post' or nested 'Comment's has errors after the #submit method and incorporates its errors." do
    params = {
      post: {
        title: 'First post',
        body: 'post body',
        comments_attributes: {
          "0" => { body: "body1" }
        }
      }
    }

    post_form = PostWithCommentValidationsForm.new(params[:post])
    post_form.valid?.should == true
    
    post_form.save
    
    post_form.should have(1).error_on(:title)
    post_form.should have(1).error_on(:comments)
    post_form.errors.size.should == 2
    post_form.comments.first.should have(1).error_on(:body)

    post_form.valid?.should == false
    post_form.should have(1).error_on(:title)
    post_form.should have(1).error_on(:comments)
    post_form.errors.size.should == 2
    post_form.comments.first.should have(1).error_on(:body)

    post_form.save

    post_form.should have(1).error_on(:title)
    post_form.should have(1).error_on(:comments)
    post_form.errors.size.should == 2
    post_form.comments.first.should have(1).error_on(:body)

    post_form.valid?.should == false
    post_form.should have(1).error_on(:title)
    post_form.should have(1).error_on(:comments)
    post_form.errors.size.should == 2
    post_form.comments.first.should have(1).error_on(:body)
  end

end
