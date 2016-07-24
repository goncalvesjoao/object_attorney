require 'object_attorney/accusation'

module ObjectAttorney

  class Allegation

    def initialize(validation)
      # expected to be an ActiveModel::Validations::<Class> instance
      @validation = validation
    end

    def founded_accusation(attorney, defendant)
      accusation = Accusation.new(@validation, attorney, defendant)

      accusation.founded ? accusation : nil
    end

  end

end
