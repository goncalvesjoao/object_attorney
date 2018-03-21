module ObjectAttorney
  class Base
    include ObjectAttorney

    defend :object

    attr_reader :object

    def initialize(object)
      @object = object
    end
  end
end
