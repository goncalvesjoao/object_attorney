module ObjectAttorney

  class Reflection
    attr_reader :name, :klass, :options

    def initialize(class_name, options)
      options = options.is_a?(Hash) ? options : { class_name: options }

      @name, @options = class_name, options

      @klass = options[:class_name] || klass_default(@name)
      @klass = @klass.constantize if @klass.is_a?(String)
    end

    def single_name
      @single_name ||= options[:single_name] || name.to_s.singularize
    end

    def plural_name
      @plural_name ||= options[:plural_name] || name.to_s.pluralize
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