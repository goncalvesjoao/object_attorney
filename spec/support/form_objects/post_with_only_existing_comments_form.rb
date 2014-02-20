class PostWithOnlyExistingCommentsForm

  include ObjectAttorney

  represents :post, properties: [:title, :body]

  has_many :comments, no_new_records: true

end
