require "spec_helper"

describe PostForm::Presenter do

  it "1. Editing a 'Post', through one property and delegating all missing methods to the represented object" do
    params = {
      post: {
        title: 'altered title',
        body: 'altered body',
        user_id: 666        
      }
    }

    post = Post.create({ title: 'First post', body: 'post body', user_id: 1 })

    post_form = described_class.new(params[:post], post)

    post_form.save.should == true

    Post.all.count.should == 1
    post = Post.first
    post.title.should == 'altered title'
    post.body.should == 'post body'
    post.user_id.should == 1

    post_form.title.should == 'altered title'
    post_form.body.should == 'post body'
    post_form.user_id.should == 1

    post_form.user_id = 665
    post_form.user_id.should == 665
  end

end


shared_examples "a PostForm with delegated properties" do

  it "1. Creating a 'Post' with 3 params, but only 2 are delegated" do
    params = {
      post: {
        title: 'First post',
        body: 'post body',
        user_id: 666
      }
    }

    post_form = described_class.new(params[:post])

    post_form.save.should == true

    Post.all.count.should == 1
    post = Post.first
    post.title.should == 'First post'
    post.body.should == nil
    post.user_id.should == 666
  end

end

describe PostForm::Properties1 do
  it_behaves_like 'a PostForm with delegated properties'
end

describe PostForm::Properties2 do
  it_behaves_like 'a PostForm with delegated properties'
end


shared_examples "a PostForm with only delegated getters" do

  it "1. Editing a 'Post' with 3 params, no changes should take place but the getters should" do
    params = {
      post: {
        title: 'altered title',
        body: 'altered body',
        user_id: 666        
      }
    }

    post = Post.create({ title: 'First post', body: 'post body', user_id: 1 })

    post_form = described_class.new(params[:post], post)

    post_form.save.should == true

    Post.all.count.should == 1
    post = Post.first
    post.title.should == 'First post'
    post.body.should == 'post body'
    post.user_id.should == 1

    post_form.title.should == 'First post'
    post_form.user_id.should == 1
    post_form.respond_to?(:body).should == false
  end

end

describe PostForm::Getters1 do
  it_behaves_like 'a PostForm with only delegated getters'
end

describe PostForm::Getters2 do
  it_behaves_like 'a PostForm with only delegated getters'
end


shared_examples "a PostForm with only delegated setters" do

  it "1. Editing a 'Post' with 3 params, changes should take place and the getters should not work" do
    params = {
      post: {
        title: 'altered title', body: 'altered body', user_id: 666
      }
    }

    post = Post.create({ title: 'First post', body: 'post body', user_id: 1 })

    post_form = described_class.new(params[:post], post)

    post_form.save.should == true

    Post.all.count.should == 1
    post = Post.first
    post.title.should == 'altered title'
    post.body.should == 'post body'
    post.user_id.should == 666

    post_form.respond_to?(:title).should == false
    post_form.respond_to?(:user_id).should == false
  end

end

describe PostForm::Setters1 do
  it_behaves_like 'a PostForm with only delegated setters'
end

describe PostForm::Setters2 do
  it_behaves_like 'a PostForm with only delegated setters'
end
