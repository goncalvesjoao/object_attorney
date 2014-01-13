
require "object_attorney/attribute_assignment"
require "object_attorney/delegation"
require "object_attorney/helpers"
require "object_attorney/naming"
require "object_attorney/reflection"
require "object_attorney/validations"
require "object_attorney/nested_objects"
require "object_attorney/record"
require "object_attorney/translation"
require "object_attorney/representation"
require 'active_record'

require "object_attorney/version"

module ObjectAttorney

  def initialize(attributes = {}, object = nil)
    initialize_nested_attributes

    attributes, object = parsing_arguments(attributes, object)

    before_initialize(attributes)

    @represented_object = object

    assign_attributes attributes

    after_initialize(attributes)
  end

  protected #################### PROTECTED METHODS DOWN BELOW ######################

  def before_initialize(attributes); end

  def after_initialize(attributes); end

  private #################### PRIVATE METHODS DOWN BELOW ######################

  def self.included(base)
    base.class_eval do
      include ActiveModel::Validations
      include ActiveModel::Validations::Callbacks
      include ActiveModel::Conversion

      include AttributeAssignment
      include Validations
      include NestedObjects
      include Record
      include Representation

      validate :validate_represented_object
    end

    base.extend(ClassMethods)
  end

  module ClassMethods
    include Naming
    include Delegation
    include Translation
  end

end
