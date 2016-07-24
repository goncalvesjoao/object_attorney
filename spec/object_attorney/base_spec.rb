require 'spec_helper'

describe ObjectAttorney::Base do

  context "Initializing an attorney with an object" do
    before do
      @user = User.new

      @user_validator = Class.new(ObjectAttorney::Base) do
        validates_presence_of :first_name
      end

      @user_validator.new(@user).valid?
    end

    it "should validate the object" do
      expect(@user.errors.messages).to eq({ first_name: ["can't be blank"] })
    end
  end

end
