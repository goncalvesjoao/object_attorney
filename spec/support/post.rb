class Post

  attr_accessor :title, :_destroy

  def initialize(attributes = {})
    (attributes || {}).each { |name, value| send("#{name}=", value) }
  end

  def marked_for_destruction?
    _destroy
  end

end
