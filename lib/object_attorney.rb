require "object_attorney/version"
require "object_attorney/try"
require "object_attorney/nested_objects"
require "object_attorney/orm"

module ObjectAttorney

  ################# EXAMPLES ##################
  # represents :user
  # accepts_nested_objects :addess, :posts
  #############################################

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

    @represented_object = represented_object(object) if object.present?

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

  protected #--------------------------------------------------protected

  def self.included(base)
    base.extend(ClassMethods)

    base.class_eval do
      include ActiveModel::Validations
      include ActiveModel::Conversion
      include ObjectAttorney::NestedObjects
      include ObjectAttorney::ORM

      validate :validate_represented_object

      def valid?
        override_validations? ? true : super
      end
    end

    base.instance_variable_set("@white_list", [])
    base.instance_variable_set("@black_list", [])
  end

  def allowed_attribute(attribute)
    attribute = attribute.to_s

    return false  if !respond_to?("#{attribute}=") || black_list.include?(attribute)
    return true   if self.class.instance_variable_get("@white_list").empty?

    self.class.instance_variable_get("@white_list").include?(attribute)
  end

  def black_list
    [*self.class.instance_variable_get("@black_list"), "_destroy"]
  end

  def validate_represented_object
    valid = override_validations? ? true : @represented_object.try_or_return(:valid?, true)
    import_represented_object_errors unless valid
    valid
  end

  def import_represented_object_errors
    @represented_object.errors.each { |key, value| self.errors.add(key, value) }
  end

  private #------------------------------ private

  def represented_object(object)
    object.extend(ObjectAttorney::Try)
  end

  def override_validations?
    marked_for_destruction?
  end

  module ClassMethods

    def represents(represented_object, represented_object_class = nil)
      represented_object_class ||= represented_object.to_s.camelize

      define_method(represented_object) do
        @represented_object ||= get_represented_object(represented_object_class.constantize.new)
      end
    end

    def attr_white_list(*white_list)
      self.class.instance_variable_set("@white_list", white_list.map(&:to_s))
    end

    def attr_black_list(*black_list)
      self.class.instance_variable_set("@black_list", black_list.map(&:to_s))
    end

  end

end
