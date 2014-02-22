module ObjectAttorney

  module Serialization

    def attributes
      self.class.attributes_keys.reduce({}) do |data, getter|
        data[getter.to_s] = send(getter)
        data
      end
    end

    def to_hash(options = {})
      serializable_hash(options)
    end

    def to_json(options = {})
      serializable_hash(options).to_json
    end

    def self.included(base)
      base.class_eval { include ActiveModel::Serialization }
      base.extend(ClassMethods)
    end

    module ClassMethods
      
      def attributes_keys
        return @attributes_keys if defined?(@attributes_keys)

        @attributes_keys = zuper_method(:attributes_keys)
        
        @attributes_keys ||= represented_object_class.present? && represented_object_class.method_defined?(:id) ? [:id] : []
      end

      def add_attribute_key(*getters)
        attributes_keys.push(*getters) unless attributes_keys.include?(getters)
      end

    end

  end

end
