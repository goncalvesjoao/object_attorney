require "spec_helper"

describe UserForm do

  it "..." do
    params = {
      user: {
        email: 'email@gmail.com',
        address: { street: "street1" },
        comments: [
          { body: "body1" },
          { body: "body2" }
        ]
      }
    }

    user_form = UserAndCommentsForm.new(params[:user])

    expect(user_form.address.nil?).to eq(false)
    expect(user_form.comments.length).to eq(2)
  end

end
