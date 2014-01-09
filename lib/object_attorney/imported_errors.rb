module ObjectAttorney
  module ImportedErrors

    protected #################### PROTECTED METHODS DOWN BELOW ######################

    def clear_imported_errors
      @imported_errors = {}
    end

    def populate_imported_errors
      if respond_to?(:represented_object)
        represented_object.errors.each { |key, value| @imported_errors[key] = value } if represented_object.present?
      else
        errors.each { |key, value| @imported_errors[key] = value }
      end
    end

    def validate_imported_errors
      imported_errors = (@imported_errors || {})
      
      incorporate_errors_from imported_errors

      imported_errors.empty?
    end

    private #################### PRIVATE METHODS DOWN BELOW ######################
    
    def incorporate_errors_from(errors)
      errors.each { |key, value| self.errors.add(key, value) }
    end

  end
end
