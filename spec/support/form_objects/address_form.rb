class AddressForm

  include ObjectAttorney

  represents :address, properties: [:street, :city]

  belongs_to :post, class_name: PostForm::Base

end
