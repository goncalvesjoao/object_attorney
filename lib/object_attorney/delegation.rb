module ObjectAttorney

  module Delegation

    def zuper_method(method_name, *args)
      self.superclass.send(method_name, *args) if self.superclass.respond_to?(method_name)
    end

    def delegate_properties(*properties, options)
      properties.each { |property| delegate_property(property, options) }
    end

    def delegate_property(property, options)
      delegate property, "#{property}=", options
    end

  end

end
