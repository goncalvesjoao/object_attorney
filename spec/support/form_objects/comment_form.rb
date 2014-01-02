class CommentForm

  include ObjectAttorney

  represents :comment

  delegate_properties :body, to: :comment

  validates_presence_of :body

end
