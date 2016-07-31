require 'spec_helper'

describe ObjectAttorney do
  describe '.validates_length_of' do
    before do
      @length_validator = Class.new(ObjectAttorney::Base) do
        validates_length_of :first_name, maximum: 5

        validates_length_of :last_name,
                            maximum: 5,
                            message: "less than 5 if you don't mind"

        validates_length_of :fax, in: 7..8, allow_nil: true

        validates_length_of :phone_number, in: 7..8, allow_blank: true

        validates_length_of :user_name,
                            within: 6..7,
                            too_long: 'pick a shorter name',
                            too_short: 'pick a longer name'

        validates_length_of :zip_code,
                            minimum: 5,
                            too_short: 'please enter at least 5 characters'

        validates_length_of \
          :smurf_leader,
          is: 4,
          message: "papa is spelled with 4 characters... don't play me."
      end
    end

    context 'given a blank user' do
      before do
        @user = UserExtended.new
        @length_validator.new(@user).valid?
      end

      it '@user should contain errors' do
        expect(@user.errors.messages).to match a_hash_including(
          user_name: ['pick a longer name'],
          zip_code: ['please enter at least 5 characters'],
          smurf_leader: ["papa is spelled with 4 characters... don't play me."]
        )
      end
    end

    context "given an user who's attributes are all invalid" do
      before do
        @user = UserExtended.new \
          fax: '',
          zip_code: '12345',
          user_name: '12345678',
          last_name: '123456',
          first_name: '123456',
          phone_number: '',
          smurf_leader: 'papas'

        @length_validator.new(@user).valid?
      end

      it '@user should contain errors' do
        expect(@user.errors.messages).to match a_hash_including(
          first_name: ['is too long (maximum is 5 characters)'],
          last_name: ["less than 5 if you don't mind"],
          fax: ['is too short (minimum is 7 characters)'],
          user_name: ['pick a shorter name'],
          smurf_leader: ["papa is spelled with 4 characters... don't play me."]
        )
      end

      context "set user's attributes to valid ones except the :phone_number" do
        before do
          @user.errors.clear
          @user.first_name = @user.last_name = '12345'
          @user.fax = '12345678'
          @user.phone_number = '123456789'
          @user.user_name = '1234567'
          @user.smurf_leader = 'papa'
          @length_validator.new(@user).valid?
        end

        it '@user should contain errors' do
          expect(@user.errors.messages).to match a_hash_including(
            phone_number: ['is too long (maximum is 8 characters)']
          )
        end
      end
    end
  end
end
