require "spec_helper"

describe UserAndCommentsForm do

  it "1. Creating a 'User' and 'Comment's at the same time." do
    params = {
      user: {
        email: 'email@gmail.com',
        comments_attributes: {
          "0" => { body: "body1" },
          "1" => { body: "1" }
        }
      }
    }

    user_form = described_class.new(params[:user])

    user_form.save.should == true
    user_form.comments.length.should == 2

    User.all.count.should == 1
    user = User.first
    user.email.should == 'email@gmail.com'
    
    Comment.all.count.should == 2
    
    comment = Comment.find(1)
    comment.body.should == 'body1'

    comment = Comment.find(2)
    comment.body.should == '1'
  end

end
