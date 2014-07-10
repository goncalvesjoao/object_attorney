#!/usr/bin/env ruby

$LOAD_PATH << './'
$LOAD_PATH << './lib'

require 'spec/require_helper'

address_attributes = {
  street: 'street',
  city: 'city'
}

p = PostWithCommentsAndAddressForm.new(address_attributes: address_attributes)

a = AddressForm.new(post_attributes: { title: 'asd', body: 'body' })

binding.pry
