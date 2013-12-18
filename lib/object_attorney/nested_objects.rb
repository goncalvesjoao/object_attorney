module ObjectAttorney
  module NestedObjects

    def nested_objects
      self.class.nested_objects.map { |nested_object_sym| self.send(nested_object_sym) }.flatten
    end

    def mark_for_destruction
      @marked_for_destruction = true
    end

    def marked_for_destruction?
      @marked_for_destruction
    end

    def mark_for_destruction_if_necessary(object, attributes)
      return nil unless attributes.kind_of?(Hash)

      _destroy = attributes["_destroy"] || attributes[:_destroy]

      object.mark_for_destruction if ["true", "1", true].include?(_destroy)
    end

    protected #################### PROTECTED METHODS DOWN BELOW ######################

    def save_nested_objects(save_method)
      nested_objects.map do |nested_object|
        call_save_or_destroy(nested_object, save_method)
      end.all?
    end

    def validate_nested_objects
      #nested_objects.all?(&:valid?) #will not validate all nested_objects
      return true if nested_objects.reject(&:marked_for_destruction?).map(&:valid?).all?
      import_nested_objects_errors
      false
    end

    def import_nested_objects_errors
      self.class.nested_objects.map do |nested_object_sym|
        
        [*self.send(nested_object_sym)].each do |nested_object|
          nested_object.errors.full_messages.each { |message| self.errors.add(nested_object_sym, message) }
        end

      end
    end

    def get_attributes_for_existing(nested_object_name, existing_nested_object)
      attributes = send("#{nested_object_name}_attributes")
      return {} if attributes.blank?
      attributes.present? ? (attributes.values.select { |x| x[:id].to_i == existing_nested_object.id }.first || {}) : {}
    end

    private #################### PRIVATE METHODS DOWN BELOW ######################

    def self.included(base)
      base.extend(ClassMethods)

      base.class_eval do
        validate :validate_nested_objects
      end
    end

    def attributes_without_destroy(attributes)
      return nil unless attributes.kind_of?(Hash)

      _attributes = attributes.dup
      _attributes.delete("_destroy")
      _attributes.delete(:_destroy)

      _attributes
    end

    def nested_getter(nested_object_name)
      nested_instance_variable = self.instance_variable_get("@#{nested_object_name}")

      if nested_instance_variable.nil?
        nested_instance_variable = get_existing_and_new_nested_objects(nested_object_name)
        self.instance_variable_set("@#{nested_object_name}", nested_instance_variable)
      end

      nested_instance_variable
    end

    def get_existing_and_new_nested_objects(nested_object_name)
      existing_and_new_nested_objects = []
      
      update_existing_nested_objects(existing_and_new_nested_objects, nested_object_name)
      build_new_nested_objects(existing_and_new_nested_objects, nested_object_name)

      existing_and_new_nested_objects
    end

    def update_existing_nested_objects(existing_and_new_nested_objects, nested_object_name)
      (send("existing_#{nested_object_name}") || []).each do |existing_nested_object|
        attributes = get_attributes_for_existing(nested_object_name, existing_nested_object)

        mark_for_destruction_if_necessary(existing_nested_object, attributes)
        existing_nested_object.assign_attributes(attributes_without_destroy(attributes))

        existing_and_new_nested_objects << existing_nested_object
      end
    end

    def build_new_nested_objects(existing_and_new_nested_objects, nested_object_name)
      (send("#{nested_object_name}_attributes") || {}).values.each do |attributes|
        next if attributes["id"].present? || attributes[:id].present?

        new_nested_object = send("build_#{nested_object_name.to_s.singularize}", attributes_without_destroy(attributes))
        mark_for_destruction_if_necessary(new_nested_object, attributes)

        existing_and_new_nested_objects << new_nested_object
      end
    end

    module ClassMethods

      def accepts_nested_objects(nested_object_name, options = {})
        reflection = AssociationReflection.new(nested_object_name, options)
        self.instance_variable_set("@#{nested_object_name}_reflection", reflection)
        self.instance_variable_set("@association_reflections", association_reflections | [reflection])

        self.send(:attr_accessor, "#{nested_object_name}_attributes".to_sym)
        define_method(nested_object_name) { nested_getter(nested_object_name) }
      end

      def association_reflections
        self.instance_variable_get("@association_reflections") || zuper_method('association_reflections') || []
      end

      def reflect_on_association(association)
        self.instance_variable_get("@#{association}_reflection") || zuper_method('reflect_on_association', association)
      end

      def reflect_on_all_associations(macro = nil)
        macro ? association_reflections.select { |reflection| reflection.macro == macro } : association_reflections
      end

      def nested_objects
        association_reflections.map(&:name)
      end

    end

  end
end
