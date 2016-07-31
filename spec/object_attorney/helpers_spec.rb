require 'spec_helper'

describe ObjectAttorney::Helpers do
  describe '.extend_errors_if_necessary' do
    before(:all) { described_class.extend_errors_if_necessary(User.new) }

    it 'should add class_methods to the instance class' do
      expect(User).to respond_to(:human_attribute_name)
      expect(User).to respond_to(:lookup_ancestors)
      expect(User).to respond_to(:i18n_scope)
    end

    it 'should add instance_methods to the instance class' do
      expect(User.new).to respond_to(:errors)
      expect(User.new).to respond_to(:read_attribute_for_validation)
    end
  end
end
