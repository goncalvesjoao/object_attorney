require "spec_helper"

describe FormObjects::User do

  it "1. Creating a 'User' using 'FormObjects::User'." do
    params = { user: { email: 'email@gmail.com', terms_of_service: true } }

    user_form = FormObjects::User.new(params[:user])
    save_result = user_form.save

    save_result.should == true
    User.all.count.should == 1
  end

  it "2. 'FormObjects::User' becomes invalid when 'User' does and incorporates its errors." do
    user = User.new
    user.should have(1).error_on(:email)
    user.email = "email@gmail.com"
    user.should have(:no).errors_on(:email)

    user_form = FormObjects::User.new
    user_form.should have(1).error_on(:email)
    user_form.email = "email@gmail.com"
    user_form.should have(:no).errors_on(:email)
  end

  it "3. 'FormObjects::User' may require the validations of fields that 'User' doesn't have." do
    params = { user: { email: "email@gmail.com" } }

    user = User.new(params[:user])
    user.should have(:no).errors_on(:terms_of_service)

    user_form = FormObjects::User.new(params[:user])
    user_form.should have(1).error_on(:terms_of_service)
    user_form.terms_of_service = true
    user_form.should have(:no).errors_on(:terms_of_service)
  end

  it "4. 'User' can't be created if 'FormObjects::User' isn't valid." do
    params = { user: { email: 'email@gmail.com' } }
    
    user_form = FormObjects::User.new(params[:user])
    save_result = user_form.save

    save_result.should == false
    User.all.count.should == 0
  end

  it "5. 'FormObjects::User' won't allow weak params to be updated, unlike 'User'." do
    params = { user: { email: 'email@gmail.com', admin: true } }

    user = User.new(params[:user])
    user.save.should == true
    user.admin.should == true

    user_form = FormObjects::User.new(params[:user].merge({ terms_of_service: true }))
    user_form.save.should == true
    user_form.user.admin.should == false
  end

end
