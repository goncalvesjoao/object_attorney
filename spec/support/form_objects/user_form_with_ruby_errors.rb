class UserFormWithRubyErrors

  include ObjectAttorney

  represents :user, properties: [:email]

  attr_accessor :terms_of_service

  validates_acceptance_of :terms_of_service, accept: true, allow_nil: false

  def submit
    fake_var == true
  end

end
