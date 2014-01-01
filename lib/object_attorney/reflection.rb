module ObjectAttorney

  class Reflection
    attr_reader :name, :klass, :options, :single_name, :plural_name

    def initialize(class_name, options)
      options = options.is_a?(Hash) ? options : { class_name: options }

      @name, @options, @single_name, @plural_name = class_name, options, class_name.to_s.singularize, class_name.to_s.pluralize      

      @klass = options[:class_name] || klass_default(@name)
      @klass = @klass.constantize if @klass.is_a?(String)
    end

    private ################################# private

    def klass_default(class_name)
      if Helpers.plural?(class_name)
        class_name.to_s.singularize.camelize
      else
        class_name.to_s.camelize
      end
    end

  end

end