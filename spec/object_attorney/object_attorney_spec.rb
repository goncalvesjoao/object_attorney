require 'spec_helper'

describe ObjectAttorney do
  context 'When .defend was never called' do
    before do
      @user_validator = Struct.new(:user) do
        include ObjectAttorney

        validates_presence_of :first_name
      end
    end

    it '#valid? should be true' do
      expect { @user_validator.new(Object.new).valid? }.to \
        raise_error(ObjectAttorney::Errors::NoDefendantToDefendError)
    end
  end

  context 'When the defendant is nil' do
    before do
      @user_validator = Struct.new(:user) do
        include ObjectAttorney

        defend :user

        validates_presence_of :first_name
      end
    end

    it '#valid? should be true' do
      expect(@user_validator.new(nil).valid?).to be true
    end
  end

  context 'When the defendant is empty' do
    before do
      @user = User.new
      @user.posts = []

      @user_validator = Struct.new(:user) do
        include ObjectAttorney

        defend :posts, in: :user

        validates_presence_of :first_name
      end
    end

    it '#valid? should be true' do
      expect(@user_validator.new(@user).valid?).to be true
    end
  end

  context 'When the defendant is not defined' do
    before do
      @user = User.new

      @user_validator = Struct.new(:user) do
        include ObjectAttorney

        defend :posts

        validates_presence_of :first_name
      end
    end

    it '#valid? should raise an error' do
      expect { @user_validator.new(@user).valid? }.to \
        raise_error(NotImplementedError)
    end
  end

  context 'When the defendant is not defined on the parent' do
    before do
      @user = User.new

      @user_validator = Struct.new(:user) do
        include ObjectAttorney

        defend :comments, in: :user

        validates_presence_of :first_name
      end
    end

    it '#valid? should raise an error' do
      expect { @user_validator.new(@user).valid? }.to \
        raise_error(NotImplementedError)
    end
  end

  context 'When the defendant is a single object' do
    before do
      @user = User.new

      @user_validator = Struct.new(:user) do
        include ObjectAttorney

        defend :user

        validates_presence_of :first_name,
                              unless: proc { |user| user.dont_validate }
      end
    end

    it '@user.errors should mention first_name' do
      expect(@user_validator.new(@user).invalid?).to be true

      expect(@user.errors.messages).to eq(first_name: ["can't be blank"])
    end

    context 'and the unless validation is true' do
      before do
        @user = User.new(dont_validate: true)
      end

      it '@user.errors should be empty' do
        expect(@user_validator.new(@user).valid?).to be true

        expect(@user.errors.empty?).to be true
      end
    end
  end

  context 'When the defendant is an array nested inside another object' do
    before do
      @user = User.new
      @user.posts = [
        Post.new,
        Post.new(_destroy: true),
        nil,
        Post.new(title: 'yada')
      ]

      @user_validator = Struct.new(:user) do
        include ObjectAttorney

        defend :posts, in: :user

        validates_presence_of :title
      end

      @user_validator.new(@user).invalid?
    end

    it '@user.errors should mention that :posts are invalid' do
      expect(@user.errors.messages).to eq(posts: ['is invalid'])
    end

    it 'only the first @user.posts should have errors' do
      expect(@user.posts[0].errors.messages).to eq(title: ["can't be blank"])
      expect(@user.posts[1].errors.empty?).to be true
      expect(@user.posts[2]).to be_nil
      expect(@user.posts[3].errors.empty?).to be true
    end
  end

  describe 'inheritance' do
    context 'when a use case inherits from another' do
      before do
        @user1 = User.new
        @user2 = User.new
        @user3 = User.new
        @user4 = User.new

        @user_validator1 = Class.new do
          include ObjectAttorney

          defend :user

          validates_presence_of :first_name

          attr_accessor :user

          def initialize(user)
            @user = user
          end
        end

        @user_validator2 = Class.new(@user_validator1) do
          validates_presence_of :phone_number
        end

        @user_validator3 = Class.new(@user_validator2) do
          defend :users

          attr_accessor :users

          def initialize(users)
            @users = users
          end
        end

        @user_validator1.new(@user1).valid?
        @user_validator2.new(@user2).valid?
        @user_validator3.new([@user3, @user4]).valid?
      end

      it '@user_validator1.defendant_options should mention :user' do
        expect(@user_validator1.defendant_options).to eq(name: :user)
      end

      it '@user_validator2.defendant_options should mention :user' do
        expect(@user_validator2.defendant_options).to eq(name: :user)
      end

      it '@user_validator3.defendant_options should mention :users' do
        expect(@user_validator3.defendant_options).to eq(name: :users)
      end

      it '@user1.errors should ONLY mention first_name' do
        expect(@user1.errors.count).to be 1

        expect(@user1.errors.messages).to eq(first_name: ["can't be blank"])
      end

      it '@user2.errors should mention first_name and phone_number' do
        expect(@user2.errors.messages).to eq(
          first_name: ["can't be blank"],
          phone_number: ["can't be blank"]
        )

        expect(@user2.errors.count).to be 2
      end

      it '@user3.errors should mention first_name and phone_number' do
        expect(@user3.errors.messages).to eq(
          first_name: ["can't be blank"],
          phone_number: ["can't be blank"]
        )

        expect(@user3.errors.count).to be 2
      end

      it '@user4.errors should mention first_name and phone_number' do
        expect(@user4.errors.messages).to eq(
          first_name: ["can't be blank"],
          phone_number: ["can't be blank"]
        )

        expect(@user4.errors.count).to be 2
      end
    end
  end
end
