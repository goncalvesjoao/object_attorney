$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'bundler'
Bundler.setup
require 'rspec'
require 'pry'
#require 'database_cleaner'

require 'object_attorney'
require 'support/database_setup'
require 'support/active_model/validations'
require 'support/models/address'
require 'support/models/comment'
require 'support/models/post'
require 'support/models/user'

require 'support/form_objects/post_form'
require 'support/form_objects/post_validations_form'
require 'support/form_objects/comment_form'
require 'support/form_objects/post_with_comment_form'
require 'support/form_objects/post_with_comment_validations_form'
require 'support/form_objects/post_with_comments_and_address_form'
require 'support/form_objects/post_with_only_new_comments_form'
require 'support/form_objects/post_with_only_existing_comments_form'
require 'support/form_objects/bulk_posts_form'
require 'support/form_objects/bulk_posts_allow_only_existing_form'
require 'support/form_objects/bulk_posts_allow_only_new_form'
require 'support/form_objects/bulk_posts_with_form_objects_form'
require 'support/form_objects/user_and_comments_form'
require 'support/form_objects/user_form'