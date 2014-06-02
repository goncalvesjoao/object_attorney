module ObjectAttorney

  module AttributeAssignment

    def assign_attributes(attributes = {})
      return if attributes.blank?

      attributes.each do |name, value|
        name, value = check_for_hidden_nested_attributes(name, value)
        send("#{name}=", value) if allowed_attribute(name)
      end

      mark_for_destruction_if_necessary(self, attributes)
    end

    protected #################### PROTECTED METHODS DOWN BELOW ######################

    def check_for_hidden_nested_attributes(name, value)
      name_sym = name.to_sym

      reflection = self.class.reflect_on_association(name_sym)

      if reflection
        if reflection.has_many? && value.is_a?(Array)
          hash = {}
          value.each_with_index do |_value, index|
            hash[index.to_s] = _value
          end
          value = hash
        end
        name = "#{name}_attributes"
      end

      [name, value]
    end

    def parsing_arguments(attributes, object)
      if !attributes.is_a?(Hash) && object.blank?
        object = attributes
        attributes = nil
      end

      attributes = {} if attributes.blank?

      [attributes.symbolize_keys, object]
    end

    def allowed_attribute(attribute)
      respond_to?("#{attribute}=")
    end

    def attributes_without_destroy(attributes)
      return nil unless attributes.is_a?(Hash)

      _attributes = attributes.dup
      _attributes.delete("_destroy")
      _attributes.delete(:_destroy)

      _attributes.symbolize_keys
    end

    def attributes_order_destruction?(attributes)
      _destroy = attributes["_destroy"] || attributes[:_destroy]
      ["true", "1", true].include?(_destroy)
    end

  end

end
