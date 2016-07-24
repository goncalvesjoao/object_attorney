module ObjectAttorney

  class Accusation

    def initialize(validation, attorney, defendant)
      @attorney = attorney
      @defendant = defendant
      @validation = validation
    end

    def sustained?
      @validation.attorney = @attorney if @validation.respond_to?(:attorney=)

      # expected to be an ActiveModel::Validations::<Class> instance
      @validation.validate(@defendant)
    end

    def founded
      return true if options[:if].nil? && options[:unless].nil?

      if_condition_true || unless_condition_true
    end

    protected ######################## PROTECTED ###############################

    def if_condition_true
      return nil if options[:if].nil?

      Helpers.call_proc_or_method(@attorney, options[:if], @defendant)
    end

    def unless_condition_true
      return nil if options[:unless].nil?

      !Helpers.call_proc_or_method(@attorney, options[:unless], @defendant)
    end

    private ########################### PRIVATE ################################

    def options
      @validation.options
    end

  end

end
