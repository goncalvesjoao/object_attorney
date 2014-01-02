require "spec_helper"


shared_examples "a BulkPostsForm" do

  it "1. Creating multiple 'Post's, with a tabless model 'BulkPostsForm' has if it had 'accepts_nested_attributes_for :posts'" do
    params = {
      bulk_post: {
        posts_attributes: {
          "0" => { title: "My title1" },
          "1" => { title: "My title2" }
        }
      }
    }

    described_class.new(params[:bulk_post]).save
    
    Post.all.count.should == 2
  end

  it "2. Creating new 'Post', editing another and deleting yet another." do
    params = {
      bulk_post: {
        posts_attributes: {
          "0" => { title: "new post" },
          "2" => { id: 1, title: 'altered post' },
          "1" => { id: 2, title: 'to be destroyed', _destroy: true }
        }
      }
    }

    Post.create(title: "My title1")
    Post.create(title: "My title2")
    Post.all.count.should == 2
    Post.first.title.should == 'My title1'

    described_class.new(params[:bulk_post]).save
    
    Post.all.count.should == 2
    Post.find_by_id(1).title.should == 'altered post'
    Post.find_by_id(3).title.should == 'new post'
  end

end

describe BulkPostsForm::Base do
  it_behaves_like 'a BulkPostsForm'
end

describe BulkPostsForm::Explicit do
  it_behaves_like 'a BulkPostsForm'
end
