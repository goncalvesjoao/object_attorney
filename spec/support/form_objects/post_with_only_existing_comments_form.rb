class PostWithOnlyExistingCommentsForm

  include ObjectAttorney

  represents :post, properties: [:title, :body]

  has_many :comments, new_records: false

end
