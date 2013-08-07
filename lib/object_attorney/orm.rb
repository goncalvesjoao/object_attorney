module ObjectAttorney
  module ORM
  
    def new_record?
      try_or_return(@represented_object, :new_record?, true)
    end

    def persisted?
      try_or_return(@represented_object, :persisted?, false)
    end

    def save(options = {})
      save!(options, :save)
    end

    def save!(options = {}, save_method = :save!)
      before_save
      save_result = valid? ? save_represented_object(save_method, options) : false
      after_save if valid? && save_result
      save_result
    end

    def destroy(options = {})
      destroy_represented_object(options)
    end

    def call_save_or_destroy(object, save_method, options = {})
      if object == self
        @represented_object.present? ? evoke_method_on_object(@represented_object, save_method, options) : true
      else
        save_method = :destroy if check_if_marked_for_destruction?(object)
        evoke_method_on_object(object, save_method, options)
      end
    end

    protected #################### PROTECTED METHODS DOWN BELOW ######################

    def before_save; end
    def after_save; end

    def destroy_represented_object(options = {})
      return true if @represented_object.blank?
      evoke_method_on_object(@represented_object, :destroy, options)
    end

    def save_represented_object(save_method, options = {})
      return true if @represented_object.blank?
      evoke_method_on_object(@represented_object, save_method, options)
    end

    private #################### PRIVATE METHODS DOWN BELOW ######################

    def check_if_marked_for_destruction?(object)
      object.respond_to?(:marked_for_destruction?) ? object.marked_for_destruction? : false
    end

    def evoke_method_on_object(object, method, options = {})
      #if object.instance_method(method).arity > 1
        object.send(method, options)
      #else
        # object.send(method)
      #end
    end

  end
end
