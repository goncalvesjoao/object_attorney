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
        [*@methods].map { |method| @attorney.send(method, defendant) }.all?
      end

    end

  end
end
