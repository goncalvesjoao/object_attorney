require "spec_helper"

describe PostWithOnlyNewCommentsForm do

  it "1. Creating nested 'Comments' inside a PostForm that only accepts new Comments and ignores existing Comments changes." do
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

    post_form = PostWithOnlyNewCommentsForm.new(params[:post], Post.find(params[:id]))
    post_form.save
    
    comment = Comment.find_by_id(1)
    comment.body.should == 'body1'

    comment = Comment.find_by_id(2)
    comment.body.should == 'body2'

    comment = Comment.find_by_id(3)
    comment.body.should == 'new comment'
    comment.post_id.should == 1

    Comment.all.count.should == 3
    Post.first.title.should == 'altered post'

  end

end
