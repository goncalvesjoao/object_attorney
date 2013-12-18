class BulkPostsFormChild < BulkPostsForm

  attr_accessor :admin

  accepts_nested_objects :items

  validates_presence_of :admin

  ##################### BODY BELLOW THIS LINE ####################

  def build_item(attributes = {}, post = nil)
    Post.new(attributes, post)
  end

  def existing_items
    []
  end

end
