require 'spec_helper'

describe ObjectAttorney do
  describe '.validates_confirmation_of' do
    before do
      @confirmation_validator = Class.new(ObjectAttorney::Base) do
        validates_confirmation_of :email,
                                  :password,
                                  message: 'should match confirmation'
      end
    end

    context 'given an invalid user' do
      before do
        @user = UserExtended.new \
          email: 'email', password: 'password',
          email_confirmation: 'email2', password_confirmation: 'password2'
        @confirmation_validator.new(@user).valid?
      end

      it '@user should contain errors' do
        expect(@user.errors.messages).to match a_hash_including(
          email_confirmation: ['should match confirmation'],
          password_confirmation: ['should match confirmation']
        )
      end
    end
  end
end
