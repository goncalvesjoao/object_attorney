require "object_attorney/association_reflection"

module ObjectAttorney
  module NestedObjects

    def initialize_nested_attributes
      self.class.reflect_on_all_associations.each do |reflection|
        self.instance_variable_set("@#{reflection.name}_attributes", {})
      end
    end

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
        
        populate_foreign_key(self, nested_object, reflection, :has_many)
        populate_foreign_key(self, nested_object, reflection, :has_one)

        saving_result = call_save_or_destroy(nested_object, save_method)

        populate_foreign_key(self, nested_object, reflection, :belongs_to)

        saving_result

      end.all?
    end

    def validate_nested_objects
      valid = nested_objects.map do |reflection, nested_object|
        nested_object.marked_for_destruction? ? true : nested_object.valid?
      end.all?

      import_nested_objects_errors unless valid
      
      valid
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
      return nil if represented_object.blank? || check_if_marked_for_destruction?(destination) || reflection.macro != macro

      reflection.set_relational_keys(origin, destination)
    end

    def self.included(base)
      base.extend(ClassMethods)

      base.class_eval do
        validate :validate_nested_objects
      end
    end

    def attributes_without_destroy(attributes)
      return nil unless attributes.is_a?(Hash)

      _attributes = attributes.dup
      _attributes.delete("_destroy")
      _attributes.delete(:_destroy)

      _attributes
    end

    def nested_getter(nested_object_name)
      nested_instance_variable = self.instance_variable_get("@#{nested_object_name}")

      if nested_instance_variable.nil?
        reflection = self.class.reflect_on_association(nested_object_name)

        nested_instance_variable = reflection.has_many? ? get_existing_and_new_nested_objects(nested_object_name) : get_existing_or_new_nested_object(nested_object_name)

        self.instance_variable_set("@#{nested_object_name}", nested_instance_variable)
      end

      nested_instance_variable
    end

    def get_existing_or_new_nested_object(nested_object_name)
      nested_object = send("existing_#{nested_object_name}")
      attributes = send("#{nested_object_name}_attributes")

      if nested_object.present?
        #return nested_object if (attributes["id"] || attributes[:id]).to_s != nested_object.id.to_s

        nested_object.assign_attributes(attributes_without_destroy(attributes))
        mark_for_destruction_if_necessary(nested_object, attributes)
      else
        nested_object = send("build_#{Helpers.singularize(nested_object_name)}", attributes_without_destroy(attributes))
        mark_for_destruction_if_necessary(nested_object, attributes)
      end

      nested_object
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

        new_nested_object = send("build_#{Helpers.singularize(nested_object_name)}", attributes_without_destroy(attributes))
        next unless new_nested_object

        mark_for_destruction_if_necessary(new_nested_object, attributes)
        existing_and_new_nested_objects << new_nested_object
      end
    end

    def build_nested_object(nested_object_name, attributes = {})
      reflection = self.class.reflect_on_association(nested_object_name)
      
      if can_represented_object_build_nested?(reflection, nested_object_name)
        new_nested_object = build_from_represented_object(reflection, nested_object_name)

        new_nested_object = assign_attributes_or_build_nested_object(reflection, attributes, new_nested_object)
      else
        new_nested_object = reflection.klass.new(attributes)
      end

      populate_foreign_key(self, new_nested_object, reflection, :has_many)

      new_nested_object
    end

    def assign_attributes_or_build_nested_object(reflection, attributes, new_nested_object)
      real_reflection_class = self.class.represented_object_reflect_on_association(reflection.name).try(:klass)

      if reflection.klass == real_reflection_class
        new_nested_object.assign_attributes(attributes)
        new_nested_object
      else
        reflection.klass.respond_to?(:represents) ? reflection.klass.new(attributes, new_nested_object) : reflection.klass.new(attributes)
      end
    end

    def can_represented_object_build_nested?(reflection, nested_object_name)
      return false if represented_object.blank?
      
      represented_object.respond_to?("build_#{nested_object_name}") || represented_object.send(nested_object_name).respond_to?(:build)
    end

    def build_from_represented_object(reflection, nested_object_name)
      build_method = "build_#{nested_object_name}"

      if represented_object.respond_to?(build_method)
        represented_object.send(build_method)
      else
        represented_object.send(nested_object_name).build
      end
    end

    def existing_nested_objects(nested_object_name)
      nested_relection = self.class.reflect_on_association(nested_object_name)

      existing = represented_object.blank? ? nested_relection.klass.all : (represented_object.send(nested_object_name) || (nested_relection.has_many? ? [] : nil))
      
      if represented_object.present? && nested_relection.klass != self.class.represented_object_class.reflect_on_association(nested_object_name).try(:klass)
        if existing.respond_to?(:map)
          existing = existing.map { |existing_nested_object| nested_relection.klass.new({}, existing_nested_object) }
        else
          existing = nested_relection.klass.new({}, existing)
        end
      end

      existing
    end

    module ClassMethods

      def has_many(nested_object_name, options = {})
        accepts_nested_objects_overwrite_macro(nested_object_name, options, :has_many)
      end

      def has_one(nested_object_name, options = {})
        accepts_nested_objects_overwrite_macro(nested_object_name, options, :has_one)
      end

      def belongs_to(nested_object_name, options = {})
        accepts_nested_objects_overwrite_macro(nested_object_name, options, :belongs_to)
      end

      def accepts_nested_objects(nested_object_name, options = {})
        reflection = AssociationReflection.new(nested_object_name, represented_object_reflection, options)

        self.instance_variable_set("@#{nested_object_name}_reflection", reflection)
        self.instance_variable_set("@association_reflections", association_reflections | [reflection])

        self.send(:attr_accessor, "#{nested_object_name}_attributes".to_sym)

        define_method(nested_object_name) { nested_getter(nested_object_name) }
        define_method("build_#{reflection.single_name}") { |attributes = {}, nested_object = nil| build_nested_object(nested_object_name, attributes) }
        define_method("existing_#{nested_object_name}") { existing_nested_objects(nested_object_name) }

        define_nested_ids_accessor(nested_object_name, reflection)
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


      private ############################### PRIVATE METHODS ###########################

      # def define_nested_attributes_accessor(nested_object_name)
      #   self.send(:attr_writer, "#{nested_object_name}_attributes".to_sym)
      #   module_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
      #     def #{nested_object_name}_attributes; @#{nested_object_name}_attributes ||= {}; end
      #   RUBY_EVAL
      # end

      def define_nested_ids_accessor(nested_object_name, reflection)
        return nil unless reflection.has_many?

        module_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
          def #{reflection.single_name}_ids
            @#{reflection.single_name}_ids ||= nested_object_name.map(&:#{reflection.primary_key})
          end
        RUBY_EVAL
      end

      def accepts_nested_objects_overwrite_macro(nested_object_name, options, macro)
        default_options = { macro: macro }
        options = options.is_a?(Hash) ? options.merge(default_options) : default_options
        accepts_nested_objects(nested_object_name, options)
      end

    end

  end
end
