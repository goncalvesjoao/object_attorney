require "object_attorney/version"
require "object_attorney/nested_objects"
require "object_attorney/orm"

module ObjectAttorney

  def initialize(attributes = {}, object = nil, options = {})
    if !attributes.kind_of?(Hash) && object.blank?
      object = attributes
      attributes = nil
    end

    attributes = {} if attributes.blank?

    if !attributes.include?("id") && object.kind_of?(String)
      attributes["id"] = object
      object = nil
    end

    @represented_object = object if object.present?

    assign_attributes attributes
    mark_for_destruction_if_necessary(self, attributes)
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

  protected #################### PROTECTED METHODS DOWN BELOW ######################

  def allowed_attribute(attribute)
    attribute = attribute.to_s

    return false  if !respond_to?("#{attribute}=") || self.class.black_list.include?(attribute)
    return true   if self.class.white_list.empty?

    self.class.white_list.include?(attribute)
  end

  def validate_represented_object
    valid = override_validations? ? true : try_or_return(@represented_object, :valid?, true)
    import_represented_object_errors unless valid
    valid
  end

  def import_represented_object_errors
    @represented_object.errors.each { |key, value| self.errors.add(key, value) }
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

  def try_or_return(object, method, default_value)
    returning_value = object.try(method)
    returning_value.nil? ? default_value : returning_value
  end

  module ClassMethods

    def represents(represented_object, represented_object_class = nil)
      @@represented_object_class = represented_object_class || represented_object.to_s.camelize.constantize

      define_method(represented_object) do
        @represented_object ||= @@represented_object_class.new
      end
    end

    def delegate_properties(*properties, options)
      properties.each { |property| delegate_propertiy(property, options) }
    end

    def delegate_propertiy(property, options)
      delegate property, "#{property}=", options
    end

    def attr_white_list=(*white_list)
      @@white_list = white_list.map(&:to_s)
    end

    def white_list
      @@white_list ||= []
    end

    def attr_black_list(*black_list)
      @@black_list = black_list.map(&:to_s)
    end

    def black_list
      @@black_list ||= ["_destroy"]
    end

    def human_attribute_name(attribute_key_name, options = {})
      no_translation = "-- no translation --"
      
      defaults = ["object_attorney.attributes.#{name.underscore}.#{attribute_key_name}".to_sym]
      defaults << options[:default] if options[:default]
      defaults.flatten!
      defaults << no_translation
      options[:count] ||= 1
      
      translation = I18n.translate(defaults.shift, options.merge(default: defaults))

      if translation == no_translation && @@represented_object_class.respond_to?(:human_attribute_name)
        translation = @@represented_object_class.human_attribute_name(attribute_key_name, options)
      end

      translation
    end

    def model_name
      @@_model_name ||= begin
        namespace = self.parents.detect do |n|
          n.respond_to?(:use_relative_model_naming?) && n.use_relative_model_naming?
        end
        ActiveModel::Name.new(@@represented_object_class || self, namespace)
      end
    end

  end

end
