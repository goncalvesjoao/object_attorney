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
      save_result, saving_order_vs_save_result = transactional_save(save_method)
      after_save if valid? && save_result
      save_result
    end

    def destroy
      self.class.saving_order.reverse.map do |object_symbol|
        [*call_method_represented_by(object_symbol)].map do |object|
          object_symbol == :self ? destroy_represented_object : object.destroy
        end
      end
    end

    protected #################### PROTECTED METHODS DOWN BELOW ######################

    def before_save; end
    def after_save; end

    def before_represented_object; end
    def after_save_represented_object; end

    def save_represented_object(save_method)
      try_or_return(@represented_object, save_method, true)
    end

    def destroy_represented_object
      try_or_return(@represented_object, :destroy, true)
    end

    private #################### PRIVATE METHODS DOWN BELOW ######################

    def transactional_save(save_method)
      return false unless valid?

      self.class.saving_order.map do |object_symbol|
        [*call_method_represented_by(object_symbol)].map do |object|
          return false unless call_save_or_destroy(object, save_method)
        end
      end

      true
    end

    def call_save_or_destroy(object, save_method)
      if object == self
        save_represented_object_and_run_callbacks(save_method)
      else
        check_if_marked_for_destruction?(object) ? object.destroy : object.send(save_method)
      end
    end

    def save_represented_object_and_run_callbacks(save_method)
      before_represented_object
      save_result = save_represented_object(save_method)
      after_save_represented_object if save_result
      save_result
    end

    # def objects_by_saving_order
    #   self.class.saving_order.map do |object_symbol|
    #     [*call_method_represented_by(object_symbol)].map do |object|
    #       OpenStruct.new(symbol: object_symbol, object: object)
    #     end
    #   end.flatten
    # end

    def call_method_represented_by(object_symbol)
      if object_symbol == :self
        self
      else
        send(object_symbol)
      end
    end

    def check_if_marked_for_destruction?(object)
      object.respond_to?(:marked_for_destruction?) ? object.marked_for_destruction? : false
    end

    def self.included(base)
      base.extend(ClassMethods)
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
