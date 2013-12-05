require "spec_helper"

describe PostForm do

  it "PostForm becomes invalid when Post does and incorporates its errors" do
    post = Post.new
    post.should have(1).error_on(:title)
    post.title = "My title"
    post.should have(:no).errors_on(:title)
    
    post_form = PostForm.new({ state: 'draft' })
    post_form.should have(1).error_on(:title)
    post_form.title = "My title"
    post_form.should have(:no).errors_on(:title)
  end

  it "PostForm may require the presence of fields that Post doesn't" do
    params = { post: { title: "My title" } }

    post = Post.new(params[:post])
    post.should have(:no).errors_on(:state)

    post_form = PostForm.new(params[:post])
    post_form.should have(1).error_on(:state)
    post_form.state = "draft"
    post_form.should have(:no).errors_on(:state)
  end

  it "Post creation through PostForm" do
    params = { post: { state: 'public', title: "My title", body: "My body" } }
    post_form = PostForm.new(params[:post])

    expect(post_form.save).to(eq(true)) && expect(post_form.post.persisted?).to(eq(true))
  end

  it "Post can't be created if PostForm isn't valid" do
    params = { post: { title: "My title", body: "My body" } }
    post_form = PostForm.new(params[:post])

    expect(post_form.save).to(eq(false)) && expect(post_form.post.persisted?).to(eq(false))
  end

  it "Post can't be created if Post isn't valid" do
    params = { post: { state: 'public', body: "My body" } }
    post_form = PostForm.new(params[:post])

    expect(post_form.save).to(eq(false)) && expect(post_form.post.persisted?).to(eq(false))
  end

  it "PostForm won't allow weak params to be updated, unlike Post" do
    params = { post: { title: 'My title', body: "My body", admin: true } }

    post_form = PostForm.new(params[:post].merge({ state: 'public' }))
    expect(post_form.save).to(eq(true)) && expect(post_form.post.admin).to(eq(false))
    
    post = Post.new(params[:post])
    expect(post.save).to(eq(true)) && expect(post.admin).to(eq(true))
  end

end
