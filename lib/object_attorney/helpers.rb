module ObjectAttorney

  module Helpers

    extend self

    def plural?(string)
      string = string.to_s
      string == string.pluralize
    end

    def try_or_return(object, method, default_value)
      returning_value = object.try(method)
      returning_value.nil? ? default_value : returning_value
    end

  end
  
end