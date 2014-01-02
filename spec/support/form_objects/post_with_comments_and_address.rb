module FormObjects
  
  class PostWithCommentsAndAddress
    
    include ObjectAttorney

    represents :post

    delegate_properties :title, :body, to: :post

    accepts_nested_objects :comments
    
    accepts_nested_object :address

    validates_presence_of :title
    
  end

end