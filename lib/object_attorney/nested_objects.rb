module ObjectAttorney
  module NestedObjects

    def nested_objects
      unless nested_objects_updated
        @nested_objects = self.class.instance_variable_get("@nested_objects").map { |nested_object_sym| self.send(nested_object_sym) }.flatten
        nested_objects_updated = true
      end
      
      @nested_objects
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

      object.mark_for_destruction if ["true", "1"].include?(_destroy)
    end

    protected #--------------------------------------------------protected

    def self.included(base)
      base.extend(ClassMethods)

      base.class_eval do
        attr_accessor :nested_objects_updated
        validate :validate_nested_objects
      end

      base.instance_variable_set("@nested_objects", [])
    end

    def save_or_destroy_nested_objects
      result = nested_objects.map do |nested_object|
        nested_object.marked_for_destruction? ? nested_object.destroy : nested_object.save!
      end.all?

      self.errors.add(:base, "Some errors where found while saving the nested objects.") unless result

      result
    end

    def validate_nested_objects
      #nested_objects.all?(&:valid?) #will not validate all nested_objects
      return true if nested_objects.reject(&:marked_for_destruction?).map(&:valid?).all?
      import_nested_objects_errors
      false
    end

    def import_nested_objects_errors
      self.class.instance_variable_get("@nested_objects").map do |nested_object_sym|
        
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

    private #------------------------------ private

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
        next if attributes["id"].present?

        new_nested_object = send("build_#{nested_object_name.to_s.singularize}", attributes_without_destroy(attributes))
        mark_for_destruction_if_necessary(new_nested_object, attributes)

        existing_and_new_nested_objects << new_nested_object
      end
    end

    module ClassMethods

      def accepts_nested_objects(*nested_objects_list)
        self.instance_variable_set("@nested_objects", nested_objects_list)
        self.send(:attr_accessor, *nested_objects_list.map { |attribute| "#{attribute}_attributes".to_sym })
        define_nested_objects_getter_methods nested_objects_list
      end

      def reflect_on_association(association)
        nil
      end

      private #------------------------ private

      def define_nested_objects_getter_methods(nested_objects_list)
        nested_objects_list.each do |nested_object_name|
          define_method(nested_object_name) do
            nested_getter(nested_object_name)
          end
        end
      end

    end

  end
end
