class AddressForm

  include ObjectAttorney

  represents :address, properties: [:street, :city]

  belongs_to :post

end
