require "spec_helper"

describe PostValidationsForm do

  it "asd", current: true do
    post1 = Post.new
    post1.valid?.should == true
    
    post1.singleton_class.validates_presence_of :title
    # binding.pry
    post1.valid?.should == false

    post2 = Post.new
    post2.valid?.should == true
  end

  it "1. 'PostValidationsForm' becomes invalid if 'Post' has errors after the #submit method and incorporates its errors." do
    params = {
      post: {
        title: 'First post',
        body: 'post body',
        comments_attributes: {
          "0" => { body: "body1" }
        }
      }
    }

    post_form = PostValidationsForm.new(params[:post])
    post_form.valid?.should == true
    
    post_form.save
    
    post_form.should have(1).error_on(:title)
    post_form.errors.size.should == 2
    post_form.comments.first.should have(1).error_on(:body)

    post_form.valid?.should == false
    post_form.should have(1).error_on(:title)
    post_form.errors.size.should == 2
    post_form.comments.first.should have(1).error_on(:body)

    post_form.save

    post_form.should have(1).error_on(:title)
    post_form.errors.size.should == 2
    post_form.comments.first.should have(1).error_on(:body)

    post_form.valid?.should == false
    post_form.should have(1).error_on(:title)
    post_form.errors.size.should == 2
    post_form.comments.first.should have(1).error_on(:body)
  end

end
