require 'spec_helper'

describe ObjectAttorney do

  context "When the defendant is nil" do
    before do
      @user_validator = Struct.new(:user) do
        include ObjectAttorney

        defend :user

        validates_presence_of :first_name, unless: Proc.new { |user| user.dont_validate }
      end
    end

    it "#valid? should be true" do
      expect(@user_validator.new(nil).valid?).to be true
    end
  end

  context "When the defendant is empty" do
    before do
      @user = User.new
      @user.posts = []

      @user_validator = Struct.new(:user) do
        include ObjectAttorney

        defend :posts, in: :user

        validates_presence_of :first_name, unless: Proc.new { |user| user.dont_validate }
      end
    end

    it "#valid? should be true" do
      expect(@user_validator.new(@user).valid?).to be true
    end
  end

  context "When the defendant is not defined" do
    before do
      @user = User.new

      @user_validator = Struct.new(:user) do
        include ObjectAttorney

        defend :posts

        validates_presence_of :first_name, unless: Proc.new { |user| user.dont_validate }
      end
    end

    it "#valid? should raise an error" do
      expect { @user_validator.new(@user).valid? }.to raise_error NotImplementedError
    end
  end

  context "When the defendant is not defined on the parent" do
    before do
      @user = User.new

      @user_validator = Struct.new(:user) do
        include ObjectAttorney

        defend :comments, in: :user

        validates_presence_of :first_name, unless: Proc.new { |user| user.dont_validate }
      end
    end

    it "#valid? should raise an error" do
      expect { @user_validator.new(@user).valid? }.to raise_error NotImplementedError
    end
  end

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
        @user = User.new(dont_validate: true)
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
      @user.posts = [Post.new, Post.new(_destroy: true), nil, Post.new(title: 'yada')]

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
      expect(@user.posts[2]).to be_nil
      expect(@user.posts[3].errors.empty?).to be true
    end
  end

  describe "inheritance" do

    context "when a use case inherits from another that has a dependant and a validation" do
      before do
        @user = User.new

        @user_validator1 = Struct.new(:user) do
          include ObjectAttorney

          defend :user

          validates_presence_of :first_name
        end

        @user_validator2 = Class.new(@user_validator1) do
          validates_presence_of :phone_number
        end

        @user_validator2.new(@user).invalid?
      end

      it "@user.errors should mention first_name and phone_number" do
        expect(@user.errors.messages).to eq({
          first_name: ["can't be blank"],
          phone_number: ["can't be blank"]
        })
      end
    end

  end

end
