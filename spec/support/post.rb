class Post < ActiveRecord::Base
  
  attr_accessor :title, :body

  validates_presence_of :title

end
