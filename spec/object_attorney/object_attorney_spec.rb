require 'spec_helper'

describe ObjectAttorney do

  context "When the defendant is a single object" do
    before do
      @user = User.new

      @user_validator = Struct.new(:user) do
        include ObjectAttorney

        defend :user

        validates_presence_of :first_name, unless: Proc.new { |user| user.dont_validate }
      end
    end

    it "@user.errors should mention first_name" do
      expect(@user_validator.new(@user).invalid?).to be true

      expect(@user.errors.messages).to eq({ first_name: ["can't be blank"] })
    end

    context "and the unless validation is true" do
      before do
        @user = User.new('', '', true)
      end

      it "@user.errors should be empty" do
        expect(@user_validator.new(@user).valid?).to be true

        expect(@user.errors.empty?).to be true
      end
    end
  end

  context "When the defendant is an array nested inside another object" do
    before do
      @user = User.new
      @user.posts = [Post.new, Post.new(nil, true), Post.new('yada')]

      @user_validator = Struct.new(:user) do
        include ObjectAttorney

        defend :posts, in: :user

        validates_presence_of :title
      end

      @user_validator.new(@user).invalid?
    end

    it "@user.errors should mention that :posts are invalid" do
      expect(@user.errors.messages).to eq({ posts: ["is invalid"] })
    end

    it "only the first @user.posts should have errors" do
      expect(@user.posts[0].errors.messages).to eq({ title: ["can't be blank"] })
      expect(@user.posts[1].errors.empty?).to be true
      expect(@user.posts[2].errors.empty?).to be true
    end
  end

end
