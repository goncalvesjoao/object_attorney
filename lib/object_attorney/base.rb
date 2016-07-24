module ObjectAttorney

  class Base

    include ObjectAttorney

    defend :defendant

    attr_reader :defendant

    def initialize(defendant)
      @defendant = defendant
    end

  end

end
