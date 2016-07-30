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
end
