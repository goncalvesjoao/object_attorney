require "spec_helper"

describe ObjectAttorney do

  it "Posts Create" do
    params = { post: { publish: true, title: "My title", body: "My body" } }
    @post_form = PostForm.new(params[:post])
    @post_form.save
  end

end