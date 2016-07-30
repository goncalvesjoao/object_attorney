require 'object_attorney/validations/custom'
require 'object_attorney/allegation'

module ObjectAttorney
  module ClassMethods
    attr_writer :allegations, :defendant_options

    def defendant_options
      @defendant_options ||= {}
    end

    def defend(name, options = {})
      defendant_options.merge!(options.merge(name: name))
    end

    def allegations
      @allegations ||= Hash.new { |hash, key| hash[key] = [] }
    end

    def validate(*args, &block)
      allegations[nil] << Allegation.new(Validations::Custom.new(args, &block))
    end

    def validates_with(*args, &block)
      options = args.extract_options!

      args.each do |validation_class|
        store_allegations_by_attribute validation_class.new(options, &block)
      end
    end

    def store_allegations_by_attribute(validation)
      validation.attributes.each do |attribute|
        allegations[attribute.to_sym] << Allegation.new(validation)
      end
    end

    # Copy allegations on inheritance.
    def inherited(base)
      base.allegations = allegations.clone
      base.defendant_options = defendant_options.clone

      super
    end
  end
end
