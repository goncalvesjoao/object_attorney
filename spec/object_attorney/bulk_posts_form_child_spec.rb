require "spec_helper"

describe BulkPostsFormChild do

  it "Creating multiple Posts, with a tabless model 'BulkPostsFormChild' has if it had 'accepts_nested_attributes_for :posts'", current: true do
    params = {
      bulk_post: {
        admin: true,
        posts_attributes: {
          "0" => { state: "draft", title: "My title1" },
          "1" => { state: "public", title: "My title2" }
        }
      }
    }

    bulk_posts_form_child = BulkPostsFormChild.new(params[:bulk_post])
    bulk_posts_form_child.save
    
    expect(Post.all.count).to(eq(2))
  end

  it "Trying to create multiple Posts, with the same title (testing the 'validates_nested_uniqueness')" do
    params = {
      bulk_post: {
        admin: true,
        posts_attributes: {
          "0" => { state: "draft", title: "My title1" },
          "1" => { state: "public", title: "My title1" }
        }
      }
    }

    bulk_posts_form = BulkPostsFormChild.new(params[:bulk_post])
    bulk_posts_form.save
    
    # TODO: Ensure that the nested objects remember their respective errors
    # see: http://stackoverflow.com/questions/13879700/rails-model-valid-flusing-custom-errors-and-falsely-returning-true
    
    expect(Post.all.count).to(eq(0))
  end

  it "Creating new Post and editing an existing one" do
    params = {
      bulk_post: {
        admin: true,
        posts_attributes: {
          "0" => { id: 1, state: "draft", title: "Changed title" },
          "1" => { state: "public", title: "My title2" }
        }
      }
    }
    
    existing_post = Post.create(title: "My title1")
    BulkPostsFormChild.new(params[:bulk_post]).save
    existing_post.reload
    
    expect(Post.all.count).to(eq(2)) && expect(existing_post.title).to(eq('Changed title'))
  end

  it "Creating new Post and deleting an existing one" do
    params = {
      bulk_post: {
        admin: true,
        posts_attributes: {
          "0" => { id: 1, state: "draft", title: "Changed title", _destroy: true },
          "1" => { state: "public", title: "My title2" }
        }
      }
    }

    existing_post = Post.create(title: "My title1")
    BulkPostsFormChild.new(params[:bulk_post]).save
    
    expect(Post.all.count).to(eq(1)) && expect(Post.where(id: existing_post.id).present?).to(eq(false))
  end

  it "Trying to create multiple Posts, but one of them is invalid" do
    params = {
      bulk_post: {
        admin: true,
        posts_attributes: {
          "0" => { title: "My title1" },
          "1" => { state: "public", title: "My title2" }
        }
      }
    }

    BulkPostsFormChild.new(params[:bulk_post]).save

    params = {
      bulk_post: {
        admin: true,
        posts_attributes: {
          "0" => { state: 'draft', title: "My title1" },
          "1" => { state: "public" }
        }
      }
    }

    BulkPostsFormChild.new(params[:bulk_post]).save
    
    expect(Post.all.count).to(eq(0))
  end

  it "Trying to create new Post and editing an existing one, but one of them is invalid" do
    params = {
      bulk_post: {
        admin: true,
        posts_attributes: {
          "0" => { id: 1, title: "Changed title" },
          "1" => { state: "public", title: "My title2" }
        }
      }
    }

    existing_post = Post.create(title: "My title1")
    BulkPostsFormChild.new(params[:bulk_post]).save
    existing_post.reload
    
    expect(Post.all.count).to(eq(1)) && expect(existing_post.title).to(eq('My title1'))

    params = {
      bulk_post: {
        admin: true,
        posts_attributes: {
          "0" => { id: 1, state: 'draft', title: "Changed title" },
          "1" => { state: "public" }
        }
      }
    }

    BulkPostsFormChild.new(params[:bulk_post]).save
    existing_post.reload
    
    expect(Post.all.count).to(eq(1)) && expect(existing_post.title).to(eq('My title1'))
  end

  it "Trying to create new Post and deleting an existing one, but the new one is invalid" do
    params = {
      bulk_post: {
        admin: true,
        posts_attributes: {
          "0" => { id: 1, state: "draft", title: "Changed title", _destroy: true },
          "1" => { state: "public" }
        }
      }
    }

    existing_post = Post.create(title: "My title1")
    BulkPostsFormChild.new(params[:bulk_post]).save
    existing_post.reload
    
    expect(Post.all.count).to(eq(1)) && expect(existing_post.title).to(eq('My title1'))
  end

  it "Trying to create new Post and deleting an existing one, the existing one is invalid but since it is marked for destruction, it should be deleted" do
    params = {
      bulk_post: {
        admin: true,
        posts_attributes: {
          "0" => { id: 1, title: "Changed title", _destroy: true },
          "1" => { state: "public", title: "My title2" }
        }
      }
    }

    existing_post = Post.create(title: "My title1")
    bulk_posts_form_child = BulkPostsFormChild.new(params[:bulk_post])
    bulk_posts_form_child.save
    
    expect(Post.all.count).to(eq(1)) && expect(Post.where(id: existing_post.id).present?).to(eq(false))
  end

  it "Trying to create new Post and deleting an existing one, both of them are invalid, no changes should occur." do
    params = {
      bulk_post: {
        admin: true,
        posts_attributes: {
          "0" => { id: 1, title: "Changed title", _destroy: true },
          "1" => { state: "public" }
        }
      }
    }

    existing_post = Post.create(title: "My title1")
    BulkPostsFormChild.new(params[:bulk_post]).save
    
    expect(Post.all.count).to(eq(1)) && expect(existing_post.title).to(eq('My title1'))
  end

end
