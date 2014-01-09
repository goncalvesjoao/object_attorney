require "spec_helper"

describe PostWithCommentsAndAddressForm do

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
          street: 'street',
          city: 'city'
        }
      }
    }

    post_form = described_class.new(params[:post])

    post_form.save.should == true
    post_form.address.present?.should == true
    
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
    address.city.should == 'city'
  end

  it "2. Checking is nestes attributes ':comments' and ':address' are initialized" do
    post_form = described_class.new
    post_form.comments_attributes.should == {}
    post_form.address_attributes.should == {}
  end

end
