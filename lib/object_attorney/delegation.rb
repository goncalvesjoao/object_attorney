module ObjectAttorney

  module Delegation

    def zuper_method(method_name, *args)
      self.superclass.send(method_name, *args) if self.superclass.respond_to?(method_name)
    end

    def properties(*_properties)
      _properties.each { |property| delegate_property(property) }
    end

    def getters(*_getters)
      _getters.each { |getter| delegate_getter(getter) }
    end

    def setters(*_setters)
      _setters.each { |getter| delegate_setter(getter) }
    end

    
    protected ##################### PROTECTED #####################

    def delegate_property(property)
      delegate_getter(property)
      delegate_setter(property)
    end

    def delegate_getter(getter)
      delegate getter, to: :represented_object
    end

    def delegate_setter(setter)
      delegate "#{setter}=", to: :represented_object
    end

  end

end
