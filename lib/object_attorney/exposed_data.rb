module ObjectAttorney

  module ExposedData

    def to_hash
      self.class.exposed_data.reduce({}) do |data, getter|
        data[getter] = send(getter)
        data
      end
    end

    def to_json(options = {})
      to_hash.to_json
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      
      def exposed_data
        return @exposed_data if defined?(@exposed_data)

        @exposed_data = zuper_method(:exposed_data)
        
        @exposed_data ||= represented_object_class.present? && represented_object_class.method_defined?(:id) ? [:id] : []
      end

      def add_exposed_data(*getters)
        exposed_data.push(*getters) unless exposed_data.include?(getters)
      end

    end

  end

end
