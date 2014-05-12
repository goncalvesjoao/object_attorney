module ActiveModel

  module Validations

    class NestedUniquenessValidator < EachValidator
      def validate_each(record, attr_name, value)
        uniq_value, existing_objects, first_element = options[:uniq_value], [], nil

        record.send(attr_name).each do |object|
          next if Helpers.marked_for_destruction?(object)

          first_element = object if first_element.nil?

          if existing_objects.include?(object.send(uniq_value))
            object.errors.add(uniq_value, :taken)
            record.errors.add(attr_name, :taken)
          else
            existing_objects << object.send(uniq_value)
          end
        end

      end
    end

    module HelperMethods
      
      def validates_nested_uniqueness(*attr_names)
        validates_with NestedUniquenessValidator, _merge_attributes(attr_names)
      end

    end
  end
end