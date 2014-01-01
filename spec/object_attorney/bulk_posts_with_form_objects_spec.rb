require "spec_helper"

shared_examples "a BulkPostsWithFormObjects" do

  it "1. If any of the 'Post's is invalid, no changes should take effect." do
    params = {
      bulk_post: {
        posts_attributes: {
          "0" => { title: "new post" },
          "1" => { id: 1, title: '' },
          "2" => { id: 2, title: 'to be destroyed', _destroy: true }
        }
      }
    }

    Post.create(title: "My title1")
    Post.create(title: "My title2")
    Post.all.count.should == 2
    Post.find_by_id(1).title.should == 'My title1'
    Post.find_by_id(2).title.should == 'My title2'

    bulk_posts_form = described_class.new(params[:bulk_post])
    bulk_posts_form.save
    
    bulk_posts_form.posts.first.should have(1).errors_on(:title)
    Post.all.count.should == 2
    Post.find_by_id(1).title.should == 'My title1'
    Post.find_by_id(2).title.should == 'My title2'
  end

  it "2. A soon to be deleted 'Post' that is invalid, should not stop all other changes." do
    params = {
      bulk_post: {
        posts_attributes: {
          "0" => { title: "new post" },
          "1" => { id: 1, title: 'altered post' },
          "2" => { id: 2, title: '', _destroy: true }
        }
      }
    }

    Post.create(title: "My title1")
    Post.create(title: "My title2")
    Post.all.count.should == 2
    Post.find_by_id(1).title.should == 'My title1'
    Post.find_by_id(2).title.should == 'My title2'

    bulk_posts_form = described_class.new(params[:bulk_post])
    bulk_posts_form.save
    
    bulk_posts_form.posts.second.id.should == 2
    bulk_posts_form.posts.second.persisted?.should == false
    bulk_posts_form.posts.second.should have(:no).errors_on(:title)
    Post.all.count.should == 2
    Post.find_by_id(1).title.should == 'altered post'
    Post.find_by_id(3).title.should == 'new post'
  end

  it "3. 'BulkPostsWithFormObjects' should be importing all of the represented objects errors." do
    params = {
      bulk_post: {
        posts_attributes: {
          "0" => { title: "" },
          "1" => { id: 1, title: '' },
          "2" => { id: 2, title: '', _destroy: true }
        }
      }
    }

    Post.create(title: "My title1")
    Post.create(title: "My title2")
    Post.all.count.should == 2

    bulk_posts_form = described_class.new(params[:bulk_post])
    bulk_posts_form.save
    
    bulk_posts_form.should have(2).errors_on(:posts)
    bulk_posts_form.posts.first.should have(1).errors_on(:title)
    bulk_posts_form.posts.second.should have(:no).errors_on(:title)
    bulk_posts_form.posts.third.should have(1).errors_on(:title)
  end

end

describe FormObjects::BulkPostsWithFormObjects::Base do
  it_behaves_like 'a BulkPostsWithFormObjects'
end

describe FormObjects::BulkPostsWithFormObjects::Explicit do
  it_behaves_like 'a BulkPostsWithFormObjects'
end
