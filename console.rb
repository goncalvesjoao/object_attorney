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


params = {
  post: {
    title: 'First post',
    body: 'post body',
    comments_attributes: {
      "0" => { body: "body1" },
      "1" => { body: "body2" }
    }
  }
}

post_form = PostForm::Base.new(params[:post])
post_form.save


post_form = PostForm::Base.new(comments_attributes: { '1' => { id: 1, body: '1', _destroy: true } })


binding.pry
