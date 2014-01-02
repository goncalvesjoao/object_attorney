class Post < ActiveRecord::Base
  
  has_many :comments
  
  has_one :address

  belongs_to :user
  
end
