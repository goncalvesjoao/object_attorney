module ObjectAttorney

  class AssociationReflection
    attr_reader :klass, :macro, :options, :name

    def initialize(association, options)
      options = options.is_a?(Hash) ? options : { class_name: options }
      
      @name = association
      @macro = options[:macro] || macro_default(association)
      @klass = options[:class_name] || klass_default(association)
      @options = options

      @klass = @klass.constantize if @klass.is_a?(String)
    end

    private ################################# private

    def macro_default(association)
      Helpers.plural?(association) ? :has_many : :belongs_to
    end

    def klass_default(association)
      if Helpers.plural?(association)
        association.to_s.singularize.camelize
      else
        association.to_s.camelize
      end
    end

  end

end