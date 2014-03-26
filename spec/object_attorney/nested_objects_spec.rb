require "spec_helper"

describe 'Testing the #reset_nested_objects method' do

  it "1. Creating 'Comments' from 'PostWithCommentForm::Base', adding another, manually and expecting the form_object to not knowing it.", current: true do
    params = {
      post: {
        title: 'new title',
        comments_attributes: {
          "0" => { body: "body1" },
          "1" => { body: "1" }
        }
      }
    }

    post_form = PostWithCommentForm::Base.new(params[:post])

    post_form.save.should == true

    Post.all.count.should == 1
    Comment.all.count.should == 2

    post_form.comments.length.should == 2

    post = Post.first
    post.comments.create(body: 'new_comment')

    post_form.post.reload
    post_form.post.comments.length.should == 3
    post_form.comments.length.should == 2
  end

  it "1. Creating 'Comments' from 'PostWithCommentForm::Base', adding another, manually and expecting the form_object to know about it.", current: true do
    params = {
      post: {
        title: 'new title',
        comments_attributes: {
          "0" => { body: "body1" },
          "1" => { body: "1" }
        }
      }
    }

    post_form = PostWithCommentForm::Base.new(params[:post])

    post_form.save.should == true

    Post.all.count.should == 1
    Comment.all.count.should == 2

    post_form.comments.length.should == 2

    post = Post.first
    post.comments.create(body: 'new_comment')

    post_form.post.reload
    post_form.post.comments.length.should == 3

    post_form.reset_nested_objects(:comments)
    post_form.comments.length.should == 3
  end

end
