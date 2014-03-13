class UserAndCommentsForm

  include ObjectAttorney

  represents :user, properties: [:email]

  has_many :comments, class_name: CommentForm, standalone: true

  has_one :address, standalone: true

end
