module ObjectAttorney
  module NestedObjects

    def mark_for_destruction
      @marked_for_destruction = true
    end

    def marked_for_destruction?
      @marked_for_destruction
    end

    def mark_for_destruction_if_necessary(object, attributes)
      return nil unless attributes.is_a?(Hash)

      _destroy = attributes["_destroy"] || attributes[:_destroy]

      object.mark_for_destruction if ["true", "1", true].include?(_destroy)
    end

    def nested_objects(macro = nil)
      nested_objects_list = []

      self.class.reflect_on_all_associations(macro).each do |reflection|
        [*self.send(reflection.name)].each do |nested_object|
          nested_objects_list << [reflection, nested_object]
        end
      end

      nested_objects_list
    end

    protected #################### PROTECTED METHODS DOWN BELOW ######################

    def save_or_destroy_nested_objects(save_method, association_macro)
      nested_objects(association_macro).map do |reflection, nested_object|
        
        populate_foreign_key(self, nested_object, reflection, :has_many) if association_macro == :has_many

        saving_result = call_save_or_destroy(nested_object, save_method)

        populate_foreign_key(nested_object, self, reflection, :belongs_to) if association_macro == :belongs_to

        saving_result

      end.all?
    end

    def validate_nested_objects
      return true if nested_objects.map do |reflection, nested_object|
        nested_object.marked_for_destruction? ? true : nested_object.valid?
      end.all?

      import_nested_objects_errors
      false
    end

    def import_nested_objects_errors
      nested_objects.each do |reflection, nested_object|
        nested_object.errors.full_messages.each { |message| self.errors.add(reflection.name, message) }
      end
    end

    def get_attributes_for_existing(nested_object_name, existing_nested_object)
      attributes = send("#{nested_object_name}_attributes")
      return {} if attributes.blank?
      attributes.present? ? (attributes.values.select { |x| x[:id].to_i == existing_nested_object.id }.first || {}) : {}
    end

    private #################### PRIVATE METHODS DOWN BELOW ######################

    def populate_foreign_key(origin, destination, reflection, macro)
      return nil if represented_object.blank? || check_if_marked_for_destruction?(destination)

      if macro == :has_many
        setter = "#{self.class.represented_object_reflection.single_name}_id="
      elsif macro == :belongs_to
        setter = "#{reflection.single_name}_id="
      end

      if destination.respond_to?(setter)
        destination.send(setter, origin.id)
      elsif destination.respond_to?("send_to_representative")
        destination.send_to_representative(setter, origin.id)
      end
    end

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
      send("existing_#{nested_object_name}").each do |existing_nested_object|
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
        next unless new_nested_object

        mark_for_destruction_if_necessary(new_nested_object, attributes)
        existing_and_new_nested_objects << new_nested_object
      end
    end

    def build_nested_object(nested_object_name, attributes = {})
      reflection = self.class.reflect_on_association(nested_object_name)
      
      new_nested_object = reflection.klass.new(attributes)

      populate_foreign_key(self, new_nested_object, reflection, :has_many) if reflection.has_many?

      new_nested_object
    end

    def existing_nested_objects(nested_object_name)
      nested_association_klass = self.class.reflect_on_association(nested_object_name).klass

      existing_list = represented_object.blank? ? nested_association_klass.all : (represented_object.send(nested_object_name) || [])
      
      if represented_object.present? && nested_association_klass != self.class.represented_object_class.reflect_on_association(nested_object_name).klass
        existing_list = existing_list.map { |existing_nested_object| nested_association_klass.new({}, existing_nested_object) }
      end

      existing_list
    end

    module ClassMethods

      def accepts_nested_object(nested_object_name, options = {})
        _accepts_nested_objects(nested_object_name, options.merge({ macro: :belongs_to }))
      end

      def accepts_nested_objects(nested_object_name, options = {})
        _accepts_nested_objects(nested_object_name, options.merge({ macro: :has_many }))
      end

      def _accepts_nested_objects(nested_object_name, options = {})
        reflection = AssociationReflection.new(nested_object_name, options)

        self.instance_variable_set("@#{nested_object_name}_reflection", reflection)
        self.instance_variable_set("@association_reflections", association_reflections | [reflection])

        self.send(:attr_accessor, "#{nested_object_name}_attributes".to_sym)

        define_method(nested_object_name) { nested_getter(nested_object_name) }
        define_method("build_#{reflection.single_name}") { |attributes = {}, nested_object = nil| build_nested_object(nested_object_name, attributes) }
        define_method("existing_#{reflection.plural_name}") { existing_nested_objects(nested_object_name) }
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

    end

  end
end
