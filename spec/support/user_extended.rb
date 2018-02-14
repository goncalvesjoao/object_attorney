require_relative 'user'

class UserExtended < User
  attr_accessor :last_name,
                :user_name,
                :zip_code,
                :fax,
                :email,
                :email_confirmation,
                :paypal_email,
                :smurf_leader,
                :password,
                :password_confirmation,
                :dont_validate_fax
end
