module ObjectAttorney
  module ORM

    def id
      represented_object.try(:id)
    end
  
    def new_record?
      Helpers.try_or_return(represented_object, :new_record?, true)
    end

    def persisted?
      Helpers.try_or_return(represented_object, :persisted?, false)
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
      return true if represented_object.blank?
      represented_object.destroy
    end

    def call_save_or_destroy(object, save_method)
      if object == self
        represented_object.present? ? represented_object.send(save_method) : true
      else
        save_method = :destroy if check_if_marked_for_destruction?(object)
        object.send(save_method)
      end
    end

    protected #################### PROTECTED METHODS DOWN BELOW ######################

    def before_save; end
    def after_save; end

    def save_after_validations(save_method)
      submit(save_method)
    end

    def submit(save_method)
      save_result = save_nested_objects(save_method, :belongs_to)
      save_result = save_represented_object(save_method) if save_result
      save_result = save_nested_objects(save_method, :has_many) if save_result
      save_result
    end

    def save_represented_object(save_method)
      return true if represented_object.blank?
      call_save_or_destroy(represented_object, save_method)
    end
    
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def all(*args)
        represented_object_class.all(*args).map { |represented_object| self.new({}, represented_object) }
      end

    end

    private #################### PRIVATE METHODS DOWN BELOW ######################

    def check_if_marked_for_destruction?(object)
      object.respond_to?(:marked_for_destruction?) ? object.marked_for_destruction? : false
    end

  end
end
