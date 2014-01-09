class PostWithCommentValidationsForm

  include ObjectAttorney

  represents :post, properties: [:title, :body]

  has_many :comments, class_name: CommentForm

  validates_presence_of :title

  def submit
    post.errors.add(:title, :blank)
    post.comments.first.errors.add(:body, :blank)
    false
  end
  
end
