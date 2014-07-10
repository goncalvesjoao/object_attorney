require "spec_helper"

describe AddressForm do

  it "FormObject with a belongs_to with a differente class then the represented_object's relation" do
    params = {
      address: {
        post_attributes: { title: 'asd', body: 'body' }
      }
    }

    address_form = AddressForm.new(params[:address])

    address_form.address.post.should == nil
    address_form.post
    address_form.address.post.should_not == nil
  end

end
