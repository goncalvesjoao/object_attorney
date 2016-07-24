class User < Struct.new(:first_name, :phone_number, :dont_validate)

  attr_accessor :posts

end
