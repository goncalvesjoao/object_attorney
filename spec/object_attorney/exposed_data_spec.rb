require "spec_helper"

describe PostForm::GrandSon do

  it "1. Editing a 'Post' with 6 params, only 2 should take place, and only 2 getters should be active" do
    params = {
      post: {
        title: 'altered title', body: 'altered body', user_id: 666, author: 'test', email: 'test@gmail.com', date: '20-10-2010'
      }
    }

    post = Post.create({ title: 'First post', body: 'post body', user_id: 1 })

    post_form = described_class.new(params[:post], post)

    post_form.save.should == true
    described_class.exposed_getters.should == [:title, :email, :author, :body, :date]
    described_class.exposed_setters.should == [:title, :user_id]

    Post.all.count.should == 1
    post = Post.first
    post.title.should == 'altered title'
    post.body.should == 'post body'
    post.user_id.should == 666
    post.respond_to?(:author).should == false
    post.respond_to?(:email).should == false
    post.respond_to?(:date).should == false

    post_form.title.should == 'altered title'
    post_form.body.should == 'post body'
    post_form.author.should == 'test'
    post_form.email.should == 'test@gmail.com'
    post_form.date.should == '20-10-2010'
    post_form.respond_to?(:user_id).should == false
    
    data = { title: "altered title", email: "test@gmail.com", author: "test", body: "post body", date: "20-10-2010" }

    post_form.exposed_data.should == data
    post_form.to_json.should == data.to_json
  end

end
