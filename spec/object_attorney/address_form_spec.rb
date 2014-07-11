require "spec_helper"

describe AddressForm do

  it "FormObject with a belongs_to with a different class then the represented_object's relation" do
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

  it "FormObject receiving a _destroy attribute, should mark the relevant represented_object, for destruction too" do
    Post.create(title: 'title', body: 'body')

    address = Address.create(street: 'street', city: 'city', post_id: 1)

    params = {
      address: {
        post_attributes: { id: 1, _destroy: true }
      }
    }

    address_form = AddressForm.new(params[:address], address)

    address_form.post.marked_for_destruction?.should == true
    address_form.address.post.marked_for_destruction?.should == true
  end

  it "FormObject initialized with a marked_for_destruction object, should reflect that" do
    address = Address.create(street: 'street', city: 'city')
    address.mark_for_destruction

    address_form = AddressForm.new({}, address)

    address_form.marked_for_destruction?.should == true
  end

end
