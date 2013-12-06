class BulkPostsFormChild < BulkPostsForm

  attr_accessor :admin

  validates_presence_of :admin

end
