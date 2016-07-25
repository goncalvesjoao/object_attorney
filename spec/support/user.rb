class User

  attr_accessor :first_name, :phone_number, :dont_validate, :posts

  def initialize(attributes = {})
    (attributes || {}).each { |name, value| send("#{name}=", value) }
  end

end
