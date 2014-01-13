module ObjectAttorney

  module Helpers

    extend self

    def is_integer?(string)
      string.match(/^(\d)+$/)
    end
    
    def singularize(class_name)
      class_name = class_name.to_s
      plural?(class_name) ? class_name.singularize : class_name
    end

    def plural?(string)
      string = string.to_s
      string == string.pluralize
    end

    def try_or_return(object, method, default_value)
      returning_value = object.try(method)
      returning_value.nil? ? default_value : returning_value
    end

    def has_errors_method?(object)
      object.present? && object.respond_to?(:errors) && !object.errors.nil?
    end
    
  end
  
end