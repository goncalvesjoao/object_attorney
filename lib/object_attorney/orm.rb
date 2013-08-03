module ObjectAttorney
  module ORM
  
    def new_record?
      @represented_object.try_or_return(:new_record?, true)
    end

    def persisted?
      @represented_object.try_or_return(:persisted?, false)
    end

    def save
      save!(:save)
    end

    def save!(method = :save!)
      before_save
      save_result = transactional_save(method)
      after_save if valid? && save_result
      save_result
    end

    def destroy
      self.class.saving_order.reverse.each do |object_symbol|
        call_method_on_symbol(:destroy, object_symbol)
      end
    end

    protected #################### PROTECTED METHODS DOWN BELOW ######################

    def before_save; end
    def after_save; end

    def save_represented_object(method = nil)
      @represented_object.try_or_return(method, true)
    end

    private #################### PRIVATE METHODS DOWN BELOW ######################

    def self.included(base)
      base.extend(ClassMethods)
    end

    def transactional_save(method)
      self.class.saving_order.each do |object_symbol|

        if object_symbol == :self
          valid? ? save_represented_object(method) : false
        else
          
          [*send(object_symbol)].each do |object|
            object.send(method)
          end

        end

      end
    end

    def call_method_on_symbol(method, object_symbol)
      if object_symbol == :self
        @represented_object.try_or_return(method, true)
      else
        [*send(object_symbol)].map { |object| object.send(method) }
      end
    end

    module ClassMethods

      def saving_order(*saving_order_list)
        if saving_order_list.blank?
          @saving_order ||= [:self, *self.instance_variable_get("@nested_objects")]
        else
          @saving_order = saving_order_list
        end
      end

    end

  end
end
