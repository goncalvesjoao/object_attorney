module FormObjects
  
  class User

    include ObjectAttorney

    represents :user

    delegate_properties :email, to: :user

    attr_accessor :terms_of_service

    validates_acceptance_of :terms_of_service, accept: true, allow_nil: false

  end

end