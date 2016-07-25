module ObjectAttorney
  module Validations

    class Custom

      attr_reader :options

      attr_writer :attorney

      def initialize(args)
        @methods = args

        @options = args.extract_options!
      end

      def validate(defendant)
        [*@methods].all? do |method|
          Helpers.call_method!(@attorney, method, defendant)
        end
      end

    end

  end
end
