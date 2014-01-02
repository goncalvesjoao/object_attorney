class PostWithCommentsAndAddressForm
  
  include ObjectAttorney

  represents :post, properties: [:title, :body]

  has_many :comments
  
  has_one :address

  validates_presence_of :title
  
end
