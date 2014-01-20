require "spec_helper"

describe UserFormWithRubyErrors do

  xit "1. 'UserFormWithRubyErrors' when saving should through an error!" do
    params = { user: { email: 'email@gmail.com', terms_of_service: true } }

    user_form = UserFormWithRubyErrors.new(params[:user])
    save_result = user_form.save

    save_result.should == true
    User.all.count.should == 1
  end

end
