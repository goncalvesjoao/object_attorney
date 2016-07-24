class Post < Struct.new(:title, :marked_for_destruction)

  def marked_for_destruction?
    self.marked_for_destruction
  end

end
