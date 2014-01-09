require "spec_helper"

shared_examples "a PostForm" do

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

    post_form.save.should == true
    post_form.comments.length.should == 2

    Post.all.count.should == 1
    post = Post.first
    post.title.should == 'First post'
    post.body.should == 'post body'
    
    post.comments.count.should == 2
    
    comment = post.comments.first
    comment.post_id.should == post.id
    comment.body.should == 'body1'
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
    
    post_form.save.should == true
    post_form.comments.length.should == 1
    
    post = Post.first
    post.title.should == 'altered post'
    
    comment = post.comments.first
    comment.post_id.should == post.id
    comment.body.should == 'altered comment'
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

    post_form.save.should == true
    post_form.comments.length.should == 1
    
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

    post_form.save.should == true
    post_form.comments.length.should == 3
    
    post = Post.first
    post.title.should == 'altered post'
    post.comments.count.should == 2

    comment = post.comments.where(id: 2).first
    comment.post_id.should == post.id
    comment.body.should == 'altered comment'

    comment = post.comments.where(id: 3).first
    comment.post_id.should == post.id
    comment.body.should == 'new comment'
  end

end

describe PostForm::Base do
  it_behaves_like 'a PostForm'
end

describe PostForm::Explicit do
  it_behaves_like 'a PostForm'
end
