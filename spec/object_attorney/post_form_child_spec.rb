require "spec_helper"

describe PostFormChild do

  it "PostFormChild becomes invalid when Post does and incorporates its errors" do
    post = Post.new
    post.should have(1).error_on(:title)
    post.title = "My title"
    post.should have(:no).errors_on(:title)

    post_form = PostFormChild.new({ state: 'draft', date: Date.today })
    post_form.should have(1).error_on(:title)
    post_form.title = "My title"
    post_form.should have(:no).errors_on(:title)
  end

  it "PostFormChild may require the validations of fields that Post doesn't have" do
    params = { post: { title: "My title" } }

    post = Post.new(params[:post])
    post.should have(:no).errors_on(:date)

    post_form = PostFormChild.new(params[:post].merge(state: 'public'))
    post_form.should have(1).error_on(:date)
    post_form.date = Date.today
    post_form.should have(:no).errors_on(:date)
  end

  it "Post creation through PostFormChild" do
    params = { post: { state: 'public', title: "My title", body: "My body", date: Date.today } }
    post_form = PostFormChild.new(params[:post])

    expect(post_form.save).to(eq(true)) && expect(post_form.post.persisted?).to(eq(true))
  end

  it "Post can't be created if PostFormChild isn't valid" do
    params = { post: { state: 'public', title: "My title", body: "My body" } }
    post_form = PostFormChild.new(params[:post])

    expect(post_form.save).to(eq(false)) && expect(post_form.post.persisted?).to(eq(false))
  end

  it "Post can't be created if Post isn't valid" do
    params = { post: { state: 'public', date: Date.today, body: "My body" } }
    post_form = PostFormChild.new(params[:post])

    expect(post_form.save).to(eq(false)) && expect(post_form.post.persisted?).to(eq(false))
  end

  it "PostFormChild won't allow weak params to be updated, unlike Post" do
    params = { post: { title: 'My title', body: "My body", admin: true } }

    post_form = PostFormChild.new(params[:post].merge({ state: 'public', date: Date.today }))
    expect(post_form.save).to(eq(true)) && expect(post_form.post.admin).to(eq(false))
    
    post = Post.new(params[:post])
    expect(post.save).to(eq(true)) && expect(post.admin).to(eq(true))
  end

end
