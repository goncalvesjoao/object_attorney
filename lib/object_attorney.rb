require "object_attorney/version"
require "object_attorney/helpers"
require "object_attorney/reflection"
require "object_attorney/nested_objects"
require "object_attorney/orm"
require 'active_record'

module ObjectAttorney

  def initialize(attributes = {}, object = nil)
    if !attributes.is_a?(Hash) && object.blank?
      object = attributes
      attributes = nil
    end

    attributes = {} if attributes.blank?

    @represented_object = object if object.present?

    assign_attributes attributes
    mark_for_destruction_if_necessary(self, attributes)

    init(attributes)
  end

  def assign_attributes(attributes = {})
    return if attributes.blank?

    attributes.each do |name, value|
      send("#{name}=", value) if allowed_attribute(name)
    end
  end

  def read_attribute_for_serialization(attribute)
    respond_to?(attribute) ? send(attribute) : nil
  end

  def send_to_representative(method_name, *args)
    return false if represented_object.blank?

    represented_object.send(method_name, *args)
  end

  protected #################### PROTECTED METHODS DOWN BELOW ######################

  def init(attributes); end

  def allowed_attribute(attribute)
    respond_to?("#{attribute}=")
  end

  def validate_represented_object
    valid = override_validations? ? true : Helpers.try_or_return(represented_object, :valid?, true)
    import_represented_object_errors unless valid
    valid
  end

  def import_represented_object_errors
    represented_object.errors.each { |key, value| self.errors.add(key, value) }
  end

  def represented_object
    @represented_object ||= self.class.represented_object_class.try(:new)
  end

  private #################### PRIVATE METHODS DOWN BELOW ######################

  def self.included(base)
    base.class_eval do
      include ActiveModel::Validations
      include ActiveModel::Validations::Callbacks
      include ActiveModel::Conversion
      include ObjectAttorney::NestedObjects
      include ObjectAttorney::ORM

      validate :validate_represented_object

      def valid?
        override_validations? ? true : super
      end
    end

    base.extend(ClassMethods)
  end

  def override_validations?
    marked_for_destruction?
  end

  module ClassMethods

    def represents(represented_object_name, options = {})
      self.instance_variable_set("@represented_object_reflection", Reflection.new(represented_object_name, options))

      define_method(represented_object_name) { represented_object }
    end

    def represented_object_reflection
      self.instance_variable_get("@represented_object_reflection") || zuper_method('represented_object_reflection')
    end

    def represented_object_class
      represented_object_reflection.try(:klass)
    end

    def zuper_method(method_name, *args)
      self.superclass.send(method_name, *args) if self.superclass.respond_to?(method_name)
    end

    def delegate_properties(*properties, options)
      properties.each { |property| delegate_property(property, options) }
    end

    def delegate_property(property, options)
      delegate property, "#{property}=", options
    end

    def human_attribute_name(attribute_key_name, options = {})
      no_translation = "-- no translation --"
      
      defaults = ["object_attorney.attributes.#{name.underscore}.#{attribute_key_name}".to_sym]
      defaults << options[:default] if options[:default]
      defaults.flatten!
      defaults << no_translation
      options[:count] ||= 1
      
      translation = I18n.translate(defaults.shift, options.merge(default: defaults))

      if translation == no_translation && represented_object_class.respond_to?(:human_attribute_name)
        translation = represented_object_class.human_attribute_name(attribute_key_name, options)
      end

      translation
    end

    def model_name
      @_model_name ||= begin
        namespace = self.parents.detect do |n|
          n.respond_to?(:use_relative_model_naming?) && n.use_relative_model_naming?
        end
        ActiveModel::Name.new(represented_object_class || self, namespace)
      end
    end

  end

end
