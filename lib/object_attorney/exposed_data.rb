module ObjectAttorney

  module ExposedData

    def exposed_data
      self.class.exposed_getters.reduce({}) do |data, getter|
        data[getter] = send(getter)
        data
      end
    end

    def to_json(options = {})
      exposed_data.to_json
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      
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

    end

  end

end
