module ObjectAttorney

  module Representation

    def read_attribute_for_serialization(attribute)
      respond_to?(attribute) ? send(attribute) : nil
    end

    def send_to_representative(method_name, *args)
      return false if represented_object.blank?

      represented_object.send(method_name, *args)
    end

    def represented_object
      @represented_object ||= self.class.represented_object_class.try(:new)
    end

    protected #################### PROTECTED METHODS DOWN BELOW ######################

    def validate_represented_object
      represented_object_valid = Helpers.try_or_return(represented_object, :valid?, true)

      load_errors_from represented_object.errors unless represented_object_valid

      nested_valid = add_errors_entry_if_nested_invalid

      represented_object_valid && nested_valid
    end

    private #################### PRIVATE METHODS DOWN BELOW ######################

    def add_errors_entry_if_nested_invalid
      nested_vs_invalid = {}

      nested_objects.each do |reflection, nested_object|
        if Helpers.has_errors_method?(nested_object) && !nested_object.errors.empty? && !nested_vs_invalid.include?(reflection.name)
          message = errors.send(:normalize_message, reflection.name, :invalid, {})

          if !errors.messages[reflection.name].try(:include?, message)
            nested_vs_invalid[reflection.name] = message
          end
        end
      end

      load_errors_from nested_vs_invalid

      nested_vs_invalid.empty?
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def table_name
        self.instance_variable_get("@table_name") || represented_object_class.try(:table_name)
      end

      attr_writer :table_name

      def represents(represented_object_name, options = {})
        self.instance_variable_set("@represented_object_reflection", Reflection.new(represented_object_name, options))

        define_method(represented_object_name) { represented_object }

        properties(*options[:properties]) if options.include?(:properties)
        getters(*options[:getters]) if options.include?(:getters)
        setters(*options[:setters]) if options.include?(:setters)

        class_eval { include Delegation::MissingMethods } if options[:delegate_missing_methods]
      end

      def represented_object_reflection
        self.instance_variable_get("@represented_object_reflection") || zuper_method('represented_object_reflection')
      end

      def represented_object_class
        represented_object_reflection.try(:klass)
      end

      def represented_object_reflect_on_association(association)
        return nil if represented_object_class.nil? || !represented_object_class.respond_to?(:reflect_on_association)

        represented_object_class.reflect_on_association(association)
      end

    end

  end

end
