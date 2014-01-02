require "spec_helper"

shared_examples "a BulkPostsAllowOnlyNewForm" do

  it "1. Tabless model 'BulkPostsAllowOnlyNewForm' only accepts new 'Post' requests and ignores editing requests." do
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
    
    Post.all.count.should == 3
    Post.find_by_id(1).title.should == 'My title1'
    Post.find_by_id(2).title.should == 'My title2'
    Post.find_by_id(3).title.should == 'new post'
  end

end

describe BulkPostsAllowOnlyNewForm::Base do
  it_behaves_like 'a BulkPostsAllowOnlyNewForm'
end

describe BulkPostsAllowOnlyNewForm::Explicit do
  it_behaves_like 'a BulkPostsAllowOnlyNewForm'
end
