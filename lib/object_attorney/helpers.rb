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
        call_method!(base, proc_or_method, object)
      end
    end

    def call_method!(base, method, *args)
      unless base.respond_to?(method)
        raise NotImplementedError, "#{base} does not respond to #{method}"
      end

      base.send(method, *args)
    end

    def extend_errors_if_necessary(object)
      return if object.respond_to?(:errors)

      object.class.send(:include, Errors)
    end
  end
end
