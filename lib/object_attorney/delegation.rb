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

    def exposed_getters
      @exposed_getters ||= (zuper_method(:exposed_getters) || [])
    end

    def add_exposed_getters(*getters)
      exposed_getters.push(*getters) unless exposed_getters.include?(getters)
    end

    def exposed_setters
      @exposed_setters ||= (zuper_method(:exposed_setters) || [])
    end

    def add_exposed_setters(*setters)
      exposed_setters.push(*setters) unless exposed_setters.include?(setters)
    end


    protected ##################### PROTECTED #####################

    def delegate_property(property)
      delegate_getter(property)
      delegate_setter(property)
    end

    def delegate_getter(getter)
      delegate getter, to: :represented_object
      add_exposed_getters(getter)
    end

    def delegate_setter(setter)
      delegate "#{setter}=", to: :represented_object
      add_exposed_setters(setter)
    end

  end

end
