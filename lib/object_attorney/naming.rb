module ObjectAttorney

  module Naming

    def model_name
      @_model_name ||= begin
        namespace = self.parents.detect do |n|
          n.respond_to?(:use_relative_model_naming?) && n.use_relative_model_naming?
        end
        ActiveModel::Name.new(represented_object_class || self, namespace)
      end
    end

  end

end
