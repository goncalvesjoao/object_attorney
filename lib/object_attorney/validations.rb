module ObjectAttorney
  module Validations

    def valid?(context = nil)
      return true if override_validations? || !Helpers.has_errors_method?(self)

      context ||= (new_record? ? :create : :update)
      output = super(context)

      load_errors_from imposed_errors

      errors.empty? && output
    end
    
    def override_validations?
      marked_for_destruction?
    end

    def clear_imposed_errors
      @imposed_errors = {}
    end

    def populate_imposed_errors
      if respond_to?(:represented_object)
        represented_object.errors.each { |key, value| @imposed_errors[key] = value } if Helpers.has_errors_method?(represented_object)
      else
        errors.each { |key, value| @imposed_errors[key] = value } if Helpers.has_errors_method?(self)
      end
    end

    def imposed_errors
      @imposed_errors ||= {}
    end

    private #################### PRIVATE METHODS DOWN BELOW ######################

    def load_errors_from(errors)
      errors.each do |key, value|
        [*value].each do |_value|
          self.errors.add(key, _value) unless self.errors.added?(key, _value)
        end
      end
    end

  end
end
