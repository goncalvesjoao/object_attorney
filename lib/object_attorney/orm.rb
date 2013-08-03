module ObjectAttorney
  module ORM
  
    def new_record?
      @represented_object.try_or_return(:new_record?, true)
    end

    def persisted?
      @represented_object.try_or_return(:persisted?, false)
    end

    def save
      save_process
    end

    def save!
      save_process true
    end

    def destroy
      @represented_object.try_or_return(:destroy, true) && nested_objects.all?(&:destroy)
    end

    protected #--------------------------------------------------protected

    def save_process(raise_exception = false)
      before_save
      save_result = raise_exception ? _save! : _save
      after_save if save_result
      save_result
    end

    def before_save; end
    def after_save; end

    def _save
      begin
        ActiveRecord::Base.transaction { _save! }
      rescue
        valid?
        false
      end
    end

    def _save!
      result = (save_or_raise_rollback! ? save_or_destroy_nested_objects : false)
      valid?
      result
    end

    def save_or_raise_rollback!
      if valid?
        save_represented_object
      else
        raise ActiveRecord::Rollback
      end
    end

    def save_represented_object
      @represented_object.try_or_return(:save!, true)
    end

  end
end
