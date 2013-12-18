module ObjectAttorney

  class RecordAssociationReflection
    attr_accessor :klass, :macro, :options, :name

    def initialize(attributes = {})
      @klass = attributes[:klass]
      @macro = attributes[:macro]
      @options = attributes[:options]
      @name = attributes[:name]
    end

    def self.new_from_sym(association)
      self.new(get_attributes_from_association(association))
    end

    private ################################# private

    def self.get_attributes_from_association(association)
      if Helpers.plural?(association)
        { name: association, macro: :has_many, klass: "::#{association.to_s.singularize.camelize}".constantize }
      else
        { name: association, macro: :belongs_to, klass: "::#{association.to_s.camelize}".constantize }
      end
    end

  end

end