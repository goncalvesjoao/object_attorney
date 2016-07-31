require 'object_attorney/validations/custom'
require 'object_attorney/accusation'

module ObjectAttorney
  class Allegation
    VALIDATION_OVERWRITES = {
      # ActiveModel::Validations::NumericalityValidator =>
      #   Validations::Numericality,
      custom: Validations::Custom
    }.freeze

    attr_reader :validation

    def initialize(validation_class, options, &block)
      overwrite_class = VALIDATION_OVERWRITES[validation_class]

      # expected to be an ActiveModel::Validations::<Class> instance
      @validation = (overwrite_class || validation_class).new(options, &block)
    end

    def attributes
      validation.attributes
    end

    def founded_accusation(attorney, defendant)
      accusation = Accusation.new(@validation, attorney, defendant)

      accusation.founded ? accusation : nil
    end
  end
end
