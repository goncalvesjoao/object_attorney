class PostForm

  include ObjectAttorney

  represents :post, Post

  delegate_properties :title, :body, to: :post

  attr_accessor :state

  validates_presence_of :state

end
