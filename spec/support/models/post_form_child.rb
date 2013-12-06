class PostFormChild < PostForm

  attr_accessor :date

  validates_presence_of :date

end
