class BulkPostsFormChild < BulkPostsForm

  attr_accessor :admin

  accepts_nested_objects :items

  validates_presence_of :admin

  ##################### BODY BELLOW THIS LINE ####################

  def build_item(attributes = {}, item = nil)
    Item.new(attributes, item)
  end

  def existing_items
    []
  end

end
