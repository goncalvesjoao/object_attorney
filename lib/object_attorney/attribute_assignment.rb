module ObjectAttorney

  module AttributeAssignment

    def assign_attributes(attributes = {})
      return if attributes.blank?

      attributes.each do |name, value|
        send("#{name}=", value) if allowed_attribute(name)
      end

      mark_for_destruction_if_necessary(self, attributes)
    end

    protected #################### PROTECTED METHODS DOWN BELOW ######################

    def parsing_arguments(attributes, object)
      if !attributes.is_a?(Hash) && object.blank?
        object = attributes
        attributes = nil
      end

      attributes = {} if attributes.blank?
    end

    def allowed_attribute(attribute)
      respond_to?("#{attribute}=")
    end

  end

end
