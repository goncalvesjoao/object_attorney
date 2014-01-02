require "spec_helper"

describe FormObjects::PostWithCommentsAndAddress do

  it "1. Creating a 'Post' with nested 'Comment's and a single 'Address'" do
    params = {
      post: {
        title: 'First post',
        body: 'post body',
        comments_attributes: {
          "0" => { body: "body1" },
          "1" => { body: "" }
        },
        address_attributes: {
          '0' => { street: 'street' }
        }
      }
    }

    post_form = described_class.new(params[:post])

    post_form.save.should == true
    
    Post.all.count.should == 1
    post = Post.first
    post.title.should == 'First post'
    post.body.should == 'post body'
    
    post.comments.count.should == 2
    
    comment = post.comments.first
    comment.post_id.should == post.id
    comment.body.should == 'body1'

    comment = post.comments.second
    comment.post_id.should == post.id
    comment.body.should == ''

    post.address.present?.should == true
    address = Address.first
    address.post_id.should == post.id
    address.street.should == 'street'
  end

end
