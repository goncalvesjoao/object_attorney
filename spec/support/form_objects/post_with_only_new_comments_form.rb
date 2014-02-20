class PostWithOnlyNewCommentsForm

  include ObjectAttorney

  represents :post, properties: [:title, :body]

  has_many :comments, existing_records: false

end
