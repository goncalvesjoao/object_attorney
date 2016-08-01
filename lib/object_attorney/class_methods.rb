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
      allegations[nil] << Allegation.new(:custom, args, &block)
    end

    def validates_with(*args, &block)
      options = args.extract_options!

      # certain ActiveModel::Validations::<Class> need this
      options[:class] = self

      args.each do |validation_class|
        allegation = Allegation.new(validation_class, options, &block)

        allegation.attributes.each do |attribute|
          allegations[attribute.to_sym].push allegation
        end
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
