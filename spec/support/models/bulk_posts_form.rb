require 'object_attorney/nested_uniqueness_validator'

class BulkPostsForm

  include ObjectAttorney

  accepts_nested_objects :posts

  validates_nested_uniqueness :posts, uniq_value: :title

  ##################### BODY BELLOW THIS LINE ####################

  def build_post(attributes = {}, post = nil)
    PostForm.new(attributes, post)
  end

  def existing_posts
    Post.all.map { |post| build_post({}, post) }
  end

end
