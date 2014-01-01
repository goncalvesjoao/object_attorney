module FormObjects
  
  class Comment

    include ObjectAttorney

    represents :comment

    delegate_properties :body, :post_id, to: :comment

    validates_presence_of :body

  end

end