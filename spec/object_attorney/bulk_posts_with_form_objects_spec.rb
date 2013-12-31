require "spec_helper"

shared_examples "a BulkPostsWithFormObjects" do

  it "1. If any of the 'Post's is invalid, no changes should take effect.", current: true do
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

    buld_posts_form = described_class.new(params[:bulk_post])
    buld_posts_form.save
    
    buld_posts_form.posts.first.should have(1).errors_on(:title)
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

    buld_posts_form = described_class.new(params[:bulk_post])
    buld_posts_form.save
    
    buld_posts_form.posts.second.id.should == 2
    buld_posts_form.posts.second.persisted?.should == false
    buld_posts_form.posts.second.should have(:no).errors_on(:title)
    Post.all.count.should == 2
    Post.find_by_id(1).title.should == 'altered post'
    Post.find_by_id(3).title.should == 'new post'
  end

end

describe FormObjects::BulkPostsWithFormObjects::Base do
  it_behaves_like 'a BulkPostsWithFormObjects'
end

describe FormObjects::BulkPostsWithFormObjects::Explicit do
  it_behaves_like 'a BulkPostsWithFormObjects'
end
