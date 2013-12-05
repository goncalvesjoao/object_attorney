class PostForm

  include ObjectAttorney

  represents :post, Post

  delegate_properties :title, :body, to: :post

  attr_accessor :publish

  validates_presence_of :publish

end
