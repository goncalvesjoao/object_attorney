module ObjectAttorney
  module Errors
    NoDefendantToDefendError = Class.new(StandardError)

    # ActiveModel::Errors told me to declare
    # the following methods for a minimal implementation
    module ClassMethods
      def human_attribute_name(attribute, _options = {})
        attribute
      end

      # Necessary for proper translations
      def lookup_ancestors
        [self]
      end

      # Necessary for proper translations
      def i18n_scope
        :activemodel
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
