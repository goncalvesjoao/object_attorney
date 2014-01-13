module ObjectAttorney
  module Validations

    def valid?(context = nil)
      return true if override_validations? || !self.respond_to?(:errors) || self.errors.nil?

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
        represented_object.errors.each { |key, value| @imposed_errors[key] = value } if represented_object.present? && represented_object.errors.present?
      else
        errors.each { |key, value| @imposed_errors[key] = value }
      end
    end

    def imposed_errors
      @imposed_errors ||= {}
    end

    private #################### PRIVATE METHODS DOWN BELOW ######################

    def load_errors_from(errors)
      errors.each { |key, value| self.errors.add(key, value) }
    end

  end
end
