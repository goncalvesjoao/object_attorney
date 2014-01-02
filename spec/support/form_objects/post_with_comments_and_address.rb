module FormObjects
  
  class PostWithCommentsAndAddress
    
    include ObjectAttorney

    represents :post

    delegate_properties :title, :body, to: :post

    has_many :comments
    
    has_one :address

    validates_presence_of :title
    
  end

end