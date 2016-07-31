require 'spec_helper'

describe ObjectAttorney do
  context 'given an attorney with a custom validation' do
    before do
      @custom_validator = Struct.new(:user) do
        include ObjectAttorney

        defend :user

        validate :phone_number_country_code, if: :should_validate_country_code

        def phone_number_country_code(user)
          return if user.phone_number.split(' ')[0] == '123'

          user.errors.add(:phone_number, 'invalid country code')
        end

        def should_validate_country_code(user)
          !user.dont_validate
        end
      end
    end

    context 'given a user with an invalid phone_number' do
      before do
        @user = User.new(phone_number: 'bad number')
        @custom_validator.new(@user).valid?
      end

      it '@user.errors should mention the bad phone_number error' do
        expect(@user.errors.added?(:phone_number, 'invalid country code')).to \
          be true
      end

      context 'and preventing the validation' do
        before do
          @user = User.new \
            dont_validate: true,
            phone_number: 'really bad number'

          @custom_validator.new(@user).valid?
        end

        it '@user.errors should be empty' do
          expect(@user.errors.empty?).to be true
        end
      end
    end

    context 'given a user with a valid phone_number' do
      before do
        @user = User.new(phone_number: '123 123')
        @custom_validator.new(@user).valid?
      end

      it '@user.errors should be empty' do
        expect(@user.errors.empty?).to be true
      end
    end
  end

  context 'given an attorney with several custom validations' do
    before do
      @custom_validator = Class.new(ObjectAttorney::Base) do
        validates_length_of :password, minimum: 6, allow_blank: true

        validates_format_of :email,
                            with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i,
                            allow_blank: true

        validates_format_of :paypal_email,
                            with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i,
                            allow_blank: true

        validate :confirm_password_confirmation, allow_blank: true

        validate :presence_of_first_name

        validate :presence_of_last_name

        def confirm_password_confirmation(user)
          return if user.password == user.password_confirmation

          user.errors.add \
            :password,
            'does not match the confirmation password'
        end

        def presence_of_first_name(user)
          return if user.first_name.present?

          user.errors.add(:gender, 'cannot be blank')
        end

        def presence_of_last_name(user)
          return if user.last_name.present?

          user.errors.add(:date_of_birth, 'cannot be blank')
        end
      end
    end

    context 'given an empty user' do
      before do
        @user = UserExtended.new
        @custom_validator.new(@user).valid?
      end

      it '@user should contain errors' do
        expect(@user.errors.messages).to match a_hash_including(
          gender: ['cannot be blank'],
          date_of_birth: ['cannot be blank']
        )
      end
    end
  end
end
