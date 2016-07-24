require 'object_attorney/errors'

module ObjectAttorney

  module Helpers

    module_function

    def marked_for_destruction?(object)
      return false unless object.respond_to?(:marked_for_destruction?)

      object.marked_for_destruction?
    end

    def call_proc_or_method(base, proc_or_method, object = nil)
      if proc_or_method.is_a?(Proc)
        base.instance_exec(object, &proc_or_method)
      else
        base.send(proc_or_method, object)
      end
    end

    def safe_call_method(base, method)
      return nil unless base.respond_to?(method)

      base.send(method)
    end

    def extend_errors_if_necessary(object)
      return if object.respond_to?(:errors)

      object.class.class_eval { include Errors }
    end

  end

end
