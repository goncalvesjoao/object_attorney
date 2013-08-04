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
      self.class.saving_order.reverse.each do |object_symbol|
        call_method_on_symbol(:destroy, object_symbol)
      end
    end

    protected #################### PROTECTED METHODS DOWN BELOW ######################

    def before_save; end
    def after_save; end

    def save_represented_object(save_method)
      try_or_return(@represented_object, save_method, true)
    end

    private #################### PRIVATE METHODS DOWN BELOW ######################

    def transactional_save(save_method)
      return false unless valid?

      saving_order_vs_save_result = {}
      
      objects_by_saving_order.each do |symbol_vs_object|
        symbol = symbol_vs_object.first[0]
        object = symbol_vs_object.first[1]

        saving_order_vs_save_result[symbol] = call_save_or_destroy(object, save_method)

        return false unless saving_order_vs_save_result[symbol]
      end

      true
    end

    def call_save_or_destroy(object, save_method)
      if object == self
        save_represented_object(save_method)
      else
        check_if_marked_for_destruction?(object) ? object.destroy : object.send(save_method)
      end
    end

    def objects_by_saving_order
      self.class.saving_order.map do |object_symbol|
        [*call_method_represented_by(object_symbol)].map do |object|
          { object_symbol => object }
        end
      end.flatten
    end

    def call_method_represented_by(object_symbol)
      if object_symbol == :self
        self
      else
        send(object_symbol)
      end
    end

    def call_method_on_symbol(method, object_symbol)
      if object_symbol == :self
        try_or_return(@represented_object, method, true)
      else
        [*send(object_symbol)].map { |object| object.send(method) }
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
