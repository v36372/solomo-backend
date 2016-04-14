class PostView < ActiveRecord::Base
  belongs_to :use
  belongs_to :post, counter_cache: :views
end