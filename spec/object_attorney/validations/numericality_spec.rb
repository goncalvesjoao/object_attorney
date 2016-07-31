require 'spec_helper'

describe ObjectAttorney do
  describe '.validates_numericality_of' do
    before do
      @numericality_validator = Class.new(ObjectAttorney::Base) do
        validates_numericality_of :phone_number

        validates_numericality_of :phone_number,
                                  less_than: ->(user) { user.fax },
                                  message: 'should be less than fax'

        validates_numericality_of \
          :fax,
          greater_than: :phone_number,
          message: 'should be greater than phone_number',
          unless: ->(user) { user.dont_validate_fax }

        validates_numericality_of :fax, odd: true, message: 'should be odd'
      end

      @numericality_validator2 = Class.new(ObjectAttorney::Base) do
        validates_numericality_of :phone_number, only_integer: true
      end
    end

    context 'given a resource with an integer phone_number' do
      before do
        @user = UserExtended.new(phone_number: 2, fax: 11)
        @numericality_validator.new(@user).valid?
      end

      it '@user should have no errors' do
        expect(@user.errors.empty?).to be true
      end
    end

    context 'given a fax smaller than a phone_number' do
      context 'and with dont_validate_fax = true' do
        before do
          @user = UserExtended.new \
            phone_number: 10, fax: 2, dont_validate_fax: true

          @numericality_validator.new(@user).valid?
        end

        it '@user should have a fax error' do
          expect(@user.errors.messages).to match a_hash_including(
            phone_number: ['should be less than fax'],
            fax: ['should be odd']
          )
        end
      end

      context 'and with dont_validate_fax = false' do
        before do
          @user = UserExtended.new(phone_number: 10, fax: 2)
          @numericality_validator.new(@user).valid?
        end

        it '@user should have a fax error' do
          expect(@user.errors.messages).to match a_hash_including(
            phone_number: ['should be less than fax'],
            fax: ['should be greater than phone_number', 'should be odd']
          )
        end
      end
    end

    context 'given a resource with a float phone_number' do
      before do
        @user = UserExtended.new(phone_number: 2.5, fax: 11)
        @numericality_validator.new(@user).valid?
      end

      it '@user should have no errors' do
        expect(@user.errors.empty?).to be true
      end
    end

    context 'given an object with a "integer" string attribute' do
      before do
        @user = UserExtended.new \
          phone_number: '2', fax: 11, dont_validate_fax: true

        @numericality_validator.new(@user).valid?
      end

      it '@user should have no errors' do
        expect(@user.errors.empty?).to be true
      end
    end

    context 'given an object with a "float" string attribute' do
      before do
        @user = UserExtended.new \
          phone_number: '2.5', fax: 11, dont_validate_fax: true

        @numericality_validator.new(@user).valid?
      end

      it '@user should have no errors' do
        expect(@user.errors.empty?).to be true
      end
    end

    context 'given an object with a none numeric string attribute' do
      before do
        @user = UserExtended.new \
          phone_number: '2.s', fax: 11, dont_validate_fax: true

        @numericality_validator.new(@user).valid?
      end

      it '@user should have an error' do
        expect(@user.errors.include?(:phone_number)).to be true
      end
    end

    context 'given a resource with an integer phone_number' do
      before do
        @user = UserExtended.new(phone_number: 2, fax: 11)
        @numericality_validator.new(@user).valid?
      end

      it '@user should have no errors' do
        expect(@user.errors.empty?).to be true
      end
    end

    context 'given a resource with a float phone_number' do
      before do
        @user = UserExtended.new(phone_number: 2.5, fax: 11)
        @numericality_validator2.new(@user).valid?
      end

      it '@user should have an error' do
        expect(@user.errors.include?(:phone_number)).to be true
      end
    end

    context 'given an object with a "float" string attribute' do
      before do
        @user = UserExtended.new(phone_number: '2.5', fax: 11)
        @numericality_validator2.new(@user).valid?
      end

      it '@user should have an error' do
        expect(@user.errors.include?(:phone_number)).to be true
      end
    end

    context 'given a resource with a string phone_number but not numeric' do
      before do
        @user = UserExtended.new \
          phone_number: '2.s', fax: 11, dont_validate_fax: true

        @numericality_validator.new(@user).valid?
      end

      it '@user should have an error' do
        expect(@user.errors.include?(:phone_number)).to be true
      end
    end
  end
end
