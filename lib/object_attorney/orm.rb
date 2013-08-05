module ObjectAttorney
  module ORM
  
    def new_record?
      try_or_return(@represented_object, :new_record?, true)
    end

    def persisted?
      try_or_return(@represented_object, :persisted?, false)
    end

    def save
      save!(:save)
    end

    def save!(save_method = :save!)
      before_save
      save_result = valid? ? save_after_validations(save_method) : false
      after_save if valid? && save_result
      save_result
    end

    def destroy
      destroy_represented_object
    end

    protected #################### PROTECTED METHODS DOWN BELOW ######################

    def before_save; end
    def after_save; end

    def save_after_validations(save_method)
      call_save_or_destroy(self, save_method)
    end

    def destroy_represented_object
      try_or_return(@represented_object, :destroy, true)
    end

    private #################### PRIVATE METHODS DOWN BELOW ######################

    def call_save_or_destroy(object, save_method)
      if object == self
        try_or_return(@represented_object, save_method, true)
      else
        check_if_marked_for_destruction?(object) ? object.destroy : object.send(save_method)
      end
    end

    def check_if_marked_for_destruction?(object)
      object.respond_to?(:marked_for_destruction?) ? object.marked_for_destruction? : false
    end

  end
end
