require "object_attorney/version"
require "object_attorney/nested_objects"

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

    @object = object if object.present?
    @trusted_data = options[:trusted_data] if options.present? && options.kind_of?(Hash)

    assign_attributes attributes
    mark_for_destruction_if_necessary(self, attributes)
  end

  def new_record?
    @object.try_or_return(:new_record?, true)
  end

  def persisted?
    @object.try_or_return(:persisted?, false)
  end

  def save
    save_process
  end

  def save!
    save_process true
  end

  def destroy
    @object.try_or_return(:destroy, true) && nested_objects.all?(&:destroy)
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

      attr_accessor :trusted_data
      validate :validate_own_object

      def valid?
        override_valid? ? true : super
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
    [*self.class.instance_variable_get("@black_list"), "trusted_data", "nested_objects_updated", "_destroy"]
  end

  def save_process(raise_exception = false)
    before_save
    save_result = raise_exception ? _save! : _save
    after_save if save_result
    save_result
  end

  def before_save; end
  def after_save; end

  def _save
    begin
      ActiveRecord::Base.transaction { _save! }
    rescue
      valid?
      false
    end
  end

  def _save!
    result = (save_or_raise_rollback! ? save_or_destroy_nested_objects : false)
    valid?
    result
  end

  def save_or_raise_rollback!
    if valid?
      save_own_object
    else
      raise ActiveRecord::Rollback
    end
  end

  def save_own_object
    @object.try_or_return(:save!, true)
  end

  def validate_own_object
    valid = override_valid? ? true : @object.try_or_return(:valid?, true)
    import_own_object_errors unless valid
    valid
  end

  def get_attributes_for_existing(nested_object_name, existing_nested_object)
    attributes = send("#{nested_object_name}_attributes")
    return {} if attributes.blank?
    attributes.present? ? (attributes.values.select { |x| x[:id].to_i == existing_nested_object.id }.first || {}) : {}
  end

  def import_own_object_errors
    @object.errors.each { |key, value| self.errors.add(key, value) }
  end

  private #------------------------------ private

  def attributes_without_destroy(attributes)
    return nil unless attributes.kind_of?(Hash)

    _attributes = attributes.dup
    _attributes.delete("_destroy")
    _attributes.delete(:_destroy)

    _attributes
  end

  def override_valid?
    marked_for_destruction?
  end

  module ClassMethods
    
    attr_accessor :own_object_class

    def represents(own_object)
      define_method(own_object) do
        own_object_class = self.class.instance_variable_get(:@own_object_class)
        own_object_class ||= own_object.to_s.camelize
        @object ||= own_object_class.constantize.new
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
