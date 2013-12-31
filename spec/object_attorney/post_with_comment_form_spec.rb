require "spec_helper"

shared_examples "a PostWithCommentForm" do

  it "1. 'Post' can't be created if any of the nested comments on 'FormObjects::PostWithCommentForm' isn't valid" do
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

    post2_form = described_class.new(params[:post])
    post2_form.save
    
    Post.all.count.should == 0
    Comment.all.count.should == 0
    post2_form.comments.second.should have(1).errors_on(:body)
  end

  it "2. Editing a 'Post', creating new nested 'Comment' (with errors), editing another and deleting yet another (none of the changes should take place)." do
    params = {
      id: 1,
      post: {
        title: "altered post",
        comments_attributes: {
          "0" => {},
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
    
    Post.first.title.should == 'My title1'
    Comment.all.count.should == 2
    Comment.find_by_id(1).body.should == 'body1'
    Comment.find_by_id(2).body.should == 'body2'
  end

  it "3. Editing a 'Post' (with errors), creating new nested 'Comment', editing another and deleting yet another (none of the changes should take place)." do
    params = {
      id: 1,
      post: {
        title: "",
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
    
    Post.first.title.should == 'My title1'
    Comment.all.count.should == 2
    Comment.find_by_id(1).body.should == 'body1'
    Comment.find_by_id(2).body.should == 'body2'
  end

  it "4. Editing a 'Post', creating new nested 'Comment', editing another and deleting (with errors) yet another (all changes should take place!)." do
    params = {
      id: 1,
      post: {
        title: "altered post",
        comments_attributes: {
          "0" => { body: "new comment" },
          "1" => { id: 1, _destroy: true },
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

describe FormObjects::PostWithCommentForm::Base do
  it_behaves_like 'a PostWithCommentForm'
end

describe FormObjects::PostWithCommentForm::Explicit do
  it_behaves_like 'a PostWithCommentForm'
end
