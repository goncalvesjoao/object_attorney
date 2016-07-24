module ObjectAttorney

  module Errors
    # ActiveModel::Errors told me to declare
    # the following methods for a minimal implementation

    module ClassMethods
      def human_attribute_name(attribute, _ = {})
        attribute
      end

      def lookup_ancestors
        [self]
      end
    end

    def self.included(base_class)
      base_class.extend ActiveModel::Naming
      base_class.extend ClassMethods
    end

    def errors
      @errors ||= ActiveModel::Errors.new(self)
    end

    def read_attribute_for_validation(attribute)
      send(attribute)
    end

  end

end
