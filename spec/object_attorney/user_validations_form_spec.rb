require "spec_helper"

describe UserValidationsForm do

  it "1. 'UserValidationsForm' becomes invalid if 'User' has errors after the #submit method and incorporates its errors.", current: true do
    user = User.new(email: "email@gmail.com")
    user.valid?.should == true

    user_form = UserValidationsForm.new(email: "email@gmail.com", terms_of_service: true)
    user_form.valid?.should == true
    user_form.save
    user_form.should have(1).error_on(:email)
  end

end
