require "spec_helper"

shared_examples "a Post" do

  it "1. Creating a 'Post' with nested 'Comment's, through 'FormObjects::Post'" do
    params = {
      post: {
        title: 'First post',
        body: 'post body',
        comments_attributes: {
          "0" => { body: "body1" },
          "1" => { body: "" }
        }
      }
    }

    post_form = described_class.new(params[:post])
    post_form.save
    
    Post.all.count.should == 1
    Comment.all.count.should == 2
  end

  it "2. Editing a 'Post' and a nested 'Comment'." do
    params = {
      id: 1,
      post: {
        title: "altered post",
        comments_attributes: {
          "0" => { id: 1, body: "altered comment" }
        }
      }
    }

    Post.create(title: "My title1")
    Post.first.title.should == 'My title1'
    Comment.create(post_id: 1, body: "body1")
    Comment.first.body.should == 'body1'

    post_form = described_class.new(params[:post], Post.find(params[:id]))
    post_form.save
    
    Post.first.title.should == 'altered post'
    Comment.first.body.should == 'altered comment'
  end

  it "3. Editing a 'Post' and deleting a nested 'Comment'." do
    params = {
      id: 1,
      post: {
        title: "altered post",
        comments_attributes: {
          "0" => { id: 1, _destroy: true }
        }
      }
    }

    Post.create(title: "My title1")
    Post.first.title.should == 'My title1'
    Comment.create(post_id: 1, body: "body1")
    Comment.all.count.should == 1

    post_form = described_class.new(params[:post], Post.find(params[:id]))
    post_form.save
    
    Post.first.title.should == 'altered post'
    Comment.all.count.should == 0
  end

  it "4. Editing a 'Post', creating new nested 'Comment', editing another and deleting yet another." do
    params = {
      id: 1,
      post: {
        title: "altered post",
        comments_attributes: {
          "0" => { body: "new comment" },
          "1" => { id: 1, body: 'to be destroyed', _destroy: true },
          "2" => { id: 2, body: 'altered comment' }
        }
      }
    }

    Post.create(title: "My title1")
    Post.first.title.should == 'My title1'
    Comment.create(post_id: 1, body: "body1")
    Comment.create(post_id: 1, body: "body2")
    Comment.all.count.should == 2

    post_form = described_class.new(params[:post], Post.find(params[:id]))
    post_form.save
    
    Post.first.title.should == 'altered post'
    Comment.all.count.should == 2
    Comment.find_by_id(2).body.should == 'altered comment'
    Comment.find_by_id(3).body.should == 'new comment'
  end

end

describe FormObjects::Post::Base do
  it_behaves_like 'a Post'
end

describe FormObjects::Post::Explicit do
  it_behaves_like 'a Post'
end
