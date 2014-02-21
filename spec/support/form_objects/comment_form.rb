class CommentForm

  include ObjectAttorney

  represents :comment

  properties :body

  validates_presence_of :body

end
