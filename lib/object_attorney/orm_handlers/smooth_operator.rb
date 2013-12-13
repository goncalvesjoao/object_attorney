module ObjectAttorney
  module OrmHandlers

    module SmoothOperator

      def save(options = {})
        save!(options, :save)
      end

      def save!(options = {}, save_method = :save!)
        before_save
        save_result = valid? ? save_after_validations(save_method, options) : false
        after_save if valid? && save_result
        save_result
      end

      def destroy(options = {})
        return true if represented_object.blank?
        evoke_method_on_object(represented_object, :destroy, options)
      end

      def call_save_or_destroy(object, save_method, options = {})
        if object == self || object == represented_object
          represented_object.present? ? evoke_method_on_object(represented_object, save_method, options) : true
        else
          save_method = :destroy if check_if_marked_for_destruction?(object)
          evoke_method_on_object(object, save_method, options)
        end
      end

      protected #################### PROTECTED METHODS DOWN BELOW ######################

      def save_after_validations(save_method, options = {})
        submit(save_method, options)
      end

      def submit(save_method, options = {})
        save_result = save_represented_object(save_method, options)
        save_result = save_nested_objects(save_method) if save_result
        save_result
      end

      def save_represented_object(save_method, options = {})
        return true if represented_object.blank?
        call_save_or_destroy(represented_object, save_method, options).ok?
      end

      def save_nested_objects(save_method, options = {})
        nested_objects.map do |nested_object|
          call_save_or_destroy(nested_object, save_method, options).ok?
        end.all?
      end

      private #################### PRIVATE METHODS DOWN BELOW ######################

      def evoke_method_on_object(object, method, options = {})
        object.send(method, options)
      end

    end

  end
end
