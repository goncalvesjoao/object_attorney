class PostWithOnlyNewCommentsForm

  include ObjectAttorney

  represents :post, properties: [:title, :body]

  has_many :comments, no_existing_records: true

end
